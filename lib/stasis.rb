# **Stasis** is an extensible static site generator.
#
# Usually Stasis is coupled with a dynamic framework like [Sinatra][si] or [Node][no].
#
# However, when coupled with `cron`, Stasis can be almost as dynamic as any framework.
#
# [si]: http://sinatrarb.com/
# [no]: http://nodejs.org/

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

require 'stasis/plugin'
require 'stasis/plugin/helpers'

require 'stasis/context/action'
require 'stasis/context/controller'

require 'stasis/plugins/after'
require 'stasis/plugins/before'
require 'stasis/plugins/helpers'
require 'stasis/plugins/ignore'
require 'stasis/plugins/layout'
require 'stasis/plugins/priority'
require 'stasis/plugins/render'

### Public Interface

class Stasis
  
  # `Hash` -- keys are directory paths, and values are instances of `Context::Controller`.
  attr_reader :controllers

  # `String` -- the destination path passed to `Stasis.new`.
  attr_reader :destination

  # `String` -- the root path passed to `Stasis.new`.
  attr_reader :root
  
  def initialize(root, destination=root+'/public')
    @destination = destination
    @root = root

    # Create a controller instance for each directory in the project.
    @controllers = Dir["#{root}/**/"].inject({}) do |hash, path|
      context = Context::Controller.new(path, root)
      hash[context._[:dir]] = context
      hash
    end
  end
  
  def generate
    # Remove old generated files.
    FileUtils.rm_rf(@destination)
    
    # Get an `Array` of all paths in the project.
    paths = Dir["#{root}/**/*"]
    
    # Reject paths that are controllers or directories.
    paths.reject! { |p| File.basename(p) == 'controller.rb' || !File.file?(p) }
    
    # Trigger all plugin `before_all` events, passing all controller instances and paths.
    @controllers, paths = trigger(:before_all, '*', controllers, paths)

    paths.uniq.each do |path|
      dir = File.dirname(path)
      path_controller = @controllers[dir]
      
      # Sometimes the path doesn't actually exist, which means a controller instance is
      # not created yet.
      path_controller ||= Context::Controller.new(dir, root)

      # Create a `Context::Action` instance which is the scope for rendering the view.
      @action = Context::Action.new(
        :path => path,
        :plugins => path_controller._[:plugins]
      )

      # Trigger all plugin `before_render` events, passing the `Context::Action` instance
      # and the current path.
      trigger(:before_render, path, @action, path)

      # Set the extension if the `path` extension is supported by [Tilt][ti].
      ext =
        Tilt.mappings.keys.detect do |ext|
          File.extname(path)[1..-1] == ext
        end

      # Render the view.
      view =
        # If the path has an extension supported by [Tilt][ti]...
        if ext
          # If a layout was specified via the `layout` method...
          if @action._[:layout]
            # Grab the controller at the same directory level as the layout.
            layout_controller = @controllers[File.dirname(@action._[:layout])]
            # Set the `Context::Action` instance's controller to the layout controller
            # for the duration block.
            controller(layout_controller) do
              # Render the layout with a block for the layout to `yield` to.
              @action.render(@action._[:layout]) do
                # Set the `Context::Action` instance's controller to the path controller
                # for the duration of the block.
                controller(path_controller) do
                  # If the controller calls `render` within the `before` block for this
                  # path, `_[:captured_render]` is set to the output of that `render`.
                  #
                  # Use `_[:captured_render]` if present, otherwise render the file
                  # located at `path`.
                  @action._[:captured_render] || @action.render(path)
                end
              end
            end
          # If a layout was not specified via the `layout` method...
          else
            # Set the `Context::Action` instance's controller to the path controller
            # for the duration block.
            controller(path_controller) do
              # Use `_[:captured_render]` if present, otherwise render the file
              # located at `path`.
              @action._[:captured_render] || @action.render(path)
            end
          end
        # If the path does not have an extension supported by [Tilt][ti] and `render` was
        # called within the `before` block for this path...
        elsif @action._[:captured_render]
          @action._[:captured_render]
        end
      
      # Trigger all plugin `after_render` events, passing the `Context::Action` instance
      # and the current path.
      trigger(:after_render, path, @action, path)

      # Cut the `root` out of the `path` to get the relative destination.
      dest = path[root.length..-1]

      # Add `@destination` (as specified from `Stasis.new`) to front of relative
      # destination.
      dest = "#{@destination}#{dest}"

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
  end

  private

  # Sets `_[:controller]` on the current `Context::Action` instance for the duration of
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
    priorities = Context::Controller.find_plugins.collect do |klass|
      klass._[:priority]
    end
    priorities.uniq.sort.each(&block)
  end

  # Trigger an event on every plugin in certain controllers (depending on the `path`
  # parameter).
  def trigger(type, path, *args, &block)
    each_priority do |priority|
      # Trigger event on all plugins in every controller.
      if path == '*'
        controllers.values.each do |controller|
          args = controller._send_to_plugin_by_type(priority, type, *args, &block)
        end
      # Trigger event on all plugins in certain controllers (see `each_directory`).
      else
        each_directory(path) do |dir|
          if cont = controllers[dir]
            controller(cont) do
              args = cont._send_to_plugin_by_type(priority, type, *args, &block)
            end
          end
        end
      end
    end
    args
  end
end