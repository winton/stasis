require 'rubygems'
require 'slim'
require 'yaml'

require File.dirname(__FILE__) + '/stasis/gems'

Stasis::Gems.activate %w(tilt)

$:.unshift File.dirname(__FILE__)

require 'stasis/plugin'
require 'stasis/plugins/after'
require 'stasis/plugins/before'
require 'stasis/plugins/destination'
require 'stasis/plugins/helpers'
require 'stasis/plugins/ignore'
require 'stasis/plugins/layout'
require 'stasis/plugins/priority'
require 'stasis/plugins/render'

class Stasis
  
  attr_reader :controllers, :root
  
  def initialize(root)
    @root = root
    @controllers = Dir["#{root}/**/controller.rb"].inject({}) do |hash, path|
      context = Context::Controller.new(path, root)
      hash[context._[:dir]] = context
      hash
    end
  end
  
  def generate(*paths)
    paths = paths.collect { |p| Dir["#{root}/#{p}"] }.flatten
    puts paths.inspect
    trigger(:before_all, '*', controllers, paths)
    puts paths.inspect
    # paths.each do |path|
    #   next unless File.file?(path)
    #   next unless Tilt.mappings.keys.include?(File.extname(path)[1..-1])
    #   rel_path = path[root.length+1..-1]
    #   context = Context::Render.new rel_path
    #   trigger :helpers, context, path
    #   trigger :before, context, path
    #   next unless context.destination
    #   template = Tilt.new path
    #   view = template.render(context)
    #   trigger :after, context, path
    #   if context.layout
    #     layout_path = "#{root}/#{context.layout}"
    #     trigger :before, context, layout_path
    #     template = Tilt.new layout_path
    #     layout = template.render(context) { view }
    #     trigger :after, context, layout_path
    #   end
    #   puts view.inspect
    #   puts layout.inspect
    # end
  end

  def trigger(type, path, *args, &block)
    if path == '*'
      controllers.values.each do |controller|
        controller._send_to_plugin_by_type(type, *args, &block)
      end
    else
      dir = File.dirname path
      while dir != File.expand_path('../', root) && dir != '/'
        if controller = controllers[dir]
          controller._send_to_plugin_by_type(type, *args, &block)
        end
        dir = File.expand_path('../', dir)
      end
    end
  end
  
  class Context
    class Controller
      
      attr_reader :_
      include Plugin::Helpers
      
      def initialize(path, root)
        @_ = {
          :dir => File.dirname(path),
          :path => path,
          :rel_dir => File.dirname(path)[root.length+1..-1],
          :root => root
        }
        @_[:plugins] = ::Stasis.constants.collect { |klass|
          klass = klass.to_s
          unless %w(Context Gems Plugin).include?(klass)
            eval("::Stasis::#{klass}").new(@_)
          end
        }.compact
        _bind_plugins(:controller_method)
        instance_eval File.read(path), path
      end
    end
    
    class Action

      attr_reader :_, :_controller, :_destination, :_source
      include Plugin::Helpers
      
      def initialize(controller)
        @_ = controller._
        @_controller = controller
        @_destination = _[:rel_path].split('.')[0..-2].join('.')
        @_source = _[:rel_path]
        _bind_plugins(:action_method)
      end
    end
  end
end