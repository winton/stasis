require 'rubygems'
require 'slim'
require 'yaml'

require File.dirname(__FILE__) + '/stasis/gems'

Stasis::Gems.activate %w(tilt)

$:.unshift File.dirname(__FILE__)

require 'stasis/plugin'
require 'stasis/plugin/helpers'

require 'stasis/context/action'
require 'stasis/context/controller'

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
    controllers, paths = trigger(:before_all, '*', controllers, paths)
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
        args = controller._send_to_plugin_by_type(type, *args, &block)
      end
    else
      dir = File.dirname path
      while dir != File.expand_path('../', root) && dir != '/'
        if controller = controllers[dir]
          args = controller._send_to_plugin_by_type(type, *args, &block)
        end
        dir = File.expand_path('../', dir)
      end
    end
    args[1..-1]
  end
end