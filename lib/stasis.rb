# **Stasis** is a dynamic framework for static sites.
#
# When coupled with [metastasis](https://github.com/winton/metastasis), Stasis can even
# respond to dynamic user input.
#
# The end goal? Making a high-performance web framework that serves pages solely through
# Nginx.

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

require 'slim' rescue nil

# Activate the [Tilt][ti] gem.

Stasis::Gems.activate %w(tilt)

# Add the project directory to the load paths.

$:.unshift File.dirname(__FILE__)

# Require all Stasis library files.

require 'stasis/auto'
require 'stasis/daemon'
require 'stasis/plugin'

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
  
  # `Hash` -- keys are directory paths, and values are instances of `Controller`.
  attr_reader :controllers

  # `String` -- the destination path passed to `Stasis.new`.
  attr_reader :destination

  # `Hash` -- options passed to `Stasis.new`.
  attr_reader :options

  # `Array` -- all paths in the project that Stasis will act upon.
  attr_reader :paths

  # `String` -- the root path passed to `Stasis.new`.
  attr_reader :root
  
  def initialize(root, destination=root+'/public', options={})
    @destination = destination
    @options = options
    @root = root

    # Create an `Array` of paths that Stasis will act upon.
    @paths = Dir["#{root}/**/*"]
    
    # Reject paths that are directories or within the destination directory.
    @paths.reject! do |path|
      !File.file?(path) || path[0..destination.length-1] == destination
    end

    # Create a controller instance for each directory in the project.
    @controllers = @paths.inject({}) do |hash, path|
      unless hash[dir = File.dirname(path)]
        scope = Controller.new(dir, root)
        hash[dir] = scope
      end
      hash
    end
  end

  def generate(options={})
    options[:only] ||= []
    options[:only] = [ options[:only] ].flatten
    options[:params] ||= {}

    # Resolve paths given via the `:only` option.
    options[:only] = options[:only].inject([]) do |array, path|
      # If `path` is a regular expression...
      if path.is_a?(::Regexp)
        array << path
      # If `path` is a file...
      elsif File.file?(path)
        array << path
      # If `root + path` is a file...
      elsif (path = File.expand_path(path, root)) && File.file?(path)
        array << path
      end
      array
    end

    if options[:only].empty?
      # Remove old generated files.
      FileUtils.rm_rf(destination)
    end

    # Reject paths that are controllers.
    @paths.reject! { |p| File.basename(p) == 'controller.rb' }
    
    # Trigger all plugin `before_all` events, passing all `Controller` instances and
    # paths.
    @controllers, @paths = trigger(:before_all, '*', @controllers, @paths)

    @paths.uniq.each do |path|
      dir = File.dirname(path)
      path_controller = @controllers[dir]

      # If `:only` option specified...
      unless options[:only].empty?
        # Skip iteration unless there is a match.
        next unless options[:only].any? do |only|
          (only.is_a?(::Regexp) && path =~ only) ||
          (only.is_a?(::String) && path == only)
        end
      end
      
      # Sometimes the path doesn't actually exist, which means a `Controller` instance
      # does not exist yet.
      path_controller ||= Controller.new(dir, root)

      # Create an `Action` instance, the scope for rendering the view.
      @action = Action.new(
        :path => path,
        :params => options[:params],
        :plugins => path_controller._[:plugins],
        :stasis => self
        )

      # Set the extension if the `path` extension is supported by [Tilt][ti].
      ext =
        Tilt.mappings.keys.detect do |ext|
          File.extname(path)[1..-1] == ext
        end
      
      # Trigger all plugin `before_render` events, passing the `Action` instance
      # and the current path.
      @action, path = trigger(:before_render, path, @action, path)

      # Render the view.
      view =
        # If the path has an extension supported by [Tilt][ti]...
        if ext
          # If a layout was specified via the `layout` method...
          if @action._[:layout]
            # Grab the controller at the same directory level as the layout.
            layout_controller = @controllers[File.dirname(@action._[:layout])]

            controller(layout_controller) do
              # Render the layout with a block for the layout to `yield` to.
              @action.render(@action._[:layout]) do
                controller(path_controller) do
                  # If the controller calls `render` within the `before` block for this
                  # path, `_[:render]` is set to the output.
                  #
                  # Use `_[:render]` if present, otherwise render the file located at
                  # `path`.
                  @action._[:render] || @action.render(path, :callback => false)
                end
              end
            end
          # If a layout was not specified...
          else
            controller(path_controller) do
              # Use `_[:render]` if present, otherwise render the file located at `path`.
              @action._[:render] || @action.render(path, :callback => false)
            end
          end
        # If the path does not have an extension supported by [Tilt][ti] and `render` was
        # called within the `before` block for this path...
        elsif @action._[:render]
          @action._[:render]
        end
      
      # Trigger all plugin `after_render` events, passing the `Action` instance and the
      # current path.
      @action, path = trigger(:after_render, path, @action, path)

      # Cut the `root` out of the `path` to get the relative destination.
      dest = path[root.length..-1]

      # Add `destination` (as specified from `Stasis.new`) to front of relative
      # destination.
      dest = "#{destination}#{dest}"

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
        File.open(dest, 'w') do |f|
          f.write(view)
        end
      # If markup was not rendered and the path exists...
      elsif File.exists?(path)
        # Copy the file located at the path to the destination path.
        FileUtils.cp(path, dest)
      end
    end

    # Trigger all plugin `after_all` events, passing all `Controller` instances and
    # paths.
    @controllers, @paths = trigger(:after_all, '*', @controllers, @paths)
  end

  # Add a plugin to all existing controller instances. This method should be called by
  # all external plugins.
  def self.register(plugin)
    ObjectSpace.each_object(::Stasis::Controller) do |controller|
      plugin = plugin.new
      controller._[:plugins] << plugin
      controller._bind_plugin(plugin, :controller_method)
    end
  end

  # Trigger an event on every plugin in certain controllers (depending on the `path`
  # parameter).
  def trigger(type, path, *args, &block)
    each_priority do |priority|
      # Trigger event on all plugins in every controller.
      if path == '*'
        @controllers.values.each do |controller|
          args = controller._send_to_plugin(priority, type, *args, &block)
        end
      # Trigger event on all plugins in certain controllers (see `each_directory`).
      else
        each_directory(path) do |dir|
          if cont = @controllers[dir]
            controller(cont) do
              args = cont._send_to_plugin(priority, type, *args, &block)
            end
          end
        end
      end
    end
    args
  end

  private

  # Sets `_[:controller]` on the current `Action` instance for the duration of
  # the block and returns the output of the block.
  def controller(controller, &block)
    old_controller = @action._[:controller]
    @action._[:controller] = controller
    output = yield
    @action._[:controller] = old_controller
    output
  end

  # Iterate through every directory between `root` and `path` (inclusive) and yield each
  # directory to a block.
  def each_directory(path, &block)
    yield(root)
    dirs = File.dirname(path)[root.length+1..-1]
    if dirs
      dirs = dirs.split('/')
      dirs.each do |dir|
        yield("#{root}/#{dir}")
      end
    end
  end

  # Iterate through plugin priority integers (sorted) and yield each to a block.
  def each_priority(&block)
    priorities = Controller.find_plugins.collect do |klass|
      klass._[:priority]
    end
    priorities.uniq.sort.each(&block)
  end
end