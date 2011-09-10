# **Stasis** is a dynamic framework for static sites.

### Prerequisites

require 'fileutils'

# `Stasis::Gems` handles loading of rubygems and gems listed in [config/gemsets.yml][ge].
#
# [ge]: https://github.com/winton/stasis/blob/master/config/gemsets.yml

require File.dirname(__FILE__) + '/stasis/gems'

# [Slim][sl] ships with its own [Tilt][ti] integration. If the user has [Slim][sl]
# installed, require it, otherwise don't worry about it.
#
# [sl]: http://slim-lang.com/
# [ti]: https://github.com/rtomayko/tilt

begin
  require 'slim'
rescue Exception => e
end

# Activate the [Tilt][ti] gem.

Stasis::Gems.activate %w(tilt)

# Add the project directory to the load paths.

$:.unshift File.dirname(__FILE__)

# Require all Stasis library files.

require 'stasis/dev_mode'
require 'stasis/plugin'
require 'stasis/server'

require 'stasis/scope'
require 'stasis/scope/action'
require 'stasis/scope/controller'

require 'stasis/plugins/before'
require 'stasis/plugins/helpers'
require 'stasis/plugins/ignore'
require 'stasis/plugins/instead'
require 'stasis/plugins/layout'
require 'stasis/plugins/priority'
require 'stasis/plugins/render'

### Public Interface

class Stasis
  
  # `Action` -- changes with each iteration of the main loop within `Stasis#render`.
  attr_accessor :action

  # `Controller` -- set to the same instance for the lifetime of the `Stasis` instance.
  attr_accessor :controller

  # `String` -- the destination path passed to `Stasis.new`.
  attr_accessor :destination

  # `String` -- changes with each iteration of the main loop within `Stasis#render`.
  attr_accessor :path

  # `Array` -- all paths in the project that Stasis will act upon.
  attr_accessor :paths

  # `Options` -- options passed to `Stasis.new`.
  attr_accessor :options

  # `Array` -- `Plugin` instances.
  attr_accessor :plugins

  # `String` -- the root path passed to `Stasis.new`.
  attr_accessor :root
  
  def initialize(root, *args)
    @options = {}
    @options = args.pop if args.last.is_a?(::Hash)
    
    @root = File.expand_path(root)
    @destination = args[0] || @root + '/public'
    @destination = File.expand_path(@destination, @root)

    # Create an `Array` of paths that Stasis will act upon.
    @paths = Dir["#{@root}/**/*"]
    
    # Reject paths that are directories or within the destination directory.
    @paths.reject! do |path|
      !File.file?(path) || path[0..@destination.length-1] == @destination
    end

    # Create plugin instances.
    @plugins = find_plugins.collect { |klass| klass.new(self) }

    # Create a controller instance.
    @controller = Controller.new(self)

    # Reject paths that are controllers.
    @paths.reject! do |path|
      if File.basename(path) == 'controller.rb'
        # Add controller to `Controller` instance.
        @controller._add(path)
        true
      else
        false
      end
    end
  end

  def render(*only)
    collect = {}
    render_options = {}

    if only.last.is_a?(::Hash)
      render_options = only.pop
    end

    # Resolve paths given via the `only` parameter.
    only = only.inject([]) do |array, path|
      # If `path` is a regular expression...
      if path.is_a?(::Regexp)
        array << path
      # If `root + path` exists...
      elsif (path = File.expand_path(path, root)) && File.exists?(path)
        array << path
      # If `path` exists...
      elsif File.exists?(path)
        array << path
      end
      array
    end

    if only.empty?
      # Remove old generated files.
      FileUtils.rm_rf(destination)
    end
    
    # Trigger all plugin `before_all` events.
    trigger(:before_all)

    @paths.uniq.each do |path|
      @path = path

      # If `only` parameters given...
      unless only.empty?
        # Skip iteration unless there is a match.
        next unless only.any? do |only|
          # Regular expression match.
          (only.is_a?(::Regexp) && @path =~ only) ||
          (
            only.is_a?(::String) && (
              # File match.
              @path == only ||
              # Directory match.
              @path[0..only.length-1] == only
            )
          )
        end
      end

      # Create an `Action` instance, the scope for rendering the view.
      @action = Action.new(self)

      # Set the extension if the `@path` extension is supported by [Tilt][ti].
      ext =
        Tilt.mappings.keys.detect do |ext|
          File.extname(@path)[1..-1] == ext
        end
      
      # Trigger all plugin `before_render` events.
      trigger(:before_render)

      # Skip if `@path` set to `nil`.
      next unless @path

      # Change current working directory.
      Dir.chdir(File.dirname(@path))

      # Render the view.
      view =
        # If the path has an extension supported by [Tilt][ti]...
        if ext
          # If the controller calls `render` within the `before` block for this
          # path, receive output from `@action._render`.
          #
          # Otherwise, render the file located at `@path`.
          output = @action._render || @action.render(@path, :callback => false)

          # If a layout was specified via the `layout` method...
          if @action._layout
            # Render the layout with a block for the layout to `yield` to.
            @action.render(@action._layout) { output }
          # If a layout was not specified...
          else
            output
          end
        # If the path does not have an extension supported by [Tilt][ti] and `render` was
        # called within the `before` block for this path...
        elsif @action._render
          @action._render
        end
      
      # Trigger all plugin `after_render` events.
      trigger(:after_render)

      # Cut the `root` out of the `path` to get the relative destination.
      relative = @path[root.length..-1]

      # Add `destination` (as specified from `Stasis.new`) to front of relative
      # destination.
      dest = "#{destination}#{relative}"

      # Cut off the extension if the extension is supported by [Tilt][ti].
      dest =
        if ext && File.extname(dest) == ".#{ext}"
          dest[0..-1*ext.length-2]
        else
          dest
        end

      # Create the directories leading up to the destination.
      FileUtils.mkdir_p(File.dirname(dest))

      # If markup was rendered...
      if view
        # Write the rendered markup to the destination.
        if render_options[:write] != false
          File.open(dest, 'w') do |f|
            f.write(view)
          end
        end
        # Collect render output.
        if render_options[:collect]
          collect[relative[1..-1]] = view
        end
      # If markup was not rendered and the path exists...
      elsif File.exists?(@path)
        # Copy the file located at the path to the destination path.
        if render_options[:write] != false
          FileUtils.cp(@path, dest)
        end
      end
    end

    # Trigger all plugin `after_all` events, passing the `Stasis` instance.
    trigger(:after_all)

    # Unset class-level instance variables.
    @action, @path = nil, nil

    # Respond with collected render output if `collect` option given.
    collect if render_options[:collect]
  end

  # Add a plugin to all existing controller instances. This method should be called by
  # all external plugins.
  def self.register(plugin)
    ObjectSpace.each_object(::Stasis) do |stasis|
      plugin = plugin.new(stasis)
      stasis.plugins << plugin
      stasis.controller._bind_plugin(plugin, :controller_method)
    end
  end

  # Trigger an event on every plugin in the controller.
  def trigger(type)
    each_priority do |priority|
      @controller._send_to_plugin(priority, type)
    end
  end

  private

  # Iterate through plugin priority integers (sorted) and yield each to a block.
  def each_priority(&block)
    priorities = @plugins.collect do |plugin|
      plugin.class._priority
    end
    priorities.uniq.sort.each(&block)
  end

  # Returns an `Array` of `Stasis::Plugin` classes.
  def find_plugins
    plugins = []
    ObjectSpace.each_object(Class) do |klass|
      if klass < ::Stasis::Plugin
        plugins << klass
      end
    end
    plugins
  end
end