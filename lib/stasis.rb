require 'rubygems'
require 'slim'
require 'yaml'

require File.dirname(__FILE__) + '/stasis/gems'

Stasis::Gems.activate %w(tilt)
require 'tilt'

$:.unshift File.dirname(__FILE__)

class Stasis
  
  attr_reader :controllers, :root
  
  def initialize(root)
    @root = root
    @controllers = Dir["#{root}/**/controller.rb"].inject({}) do |hash, path|
      context = Context::Controller.new
      context.instance_eval File.read(path), path
      hash[File.dirname(path)] = context
      hash
    end
  end
  
  def generate(*paths)
    paths.collect! { |p| "#{root}/#{p}" }
    Dir[*paths].each do |path|
      rel_path = path[root.length+1..-1]
      next unless File.file?(path)
      next unless Tilt.mappings.keys.include?(File.extname(path)[1..-1])
      context = Context::Render.new rel_path
      trigger :helpers, context, path, rel_path
      trigger :before, context, path, rel_path
      next if context.ignore
      template = Tilt.new path
      view = template.render(context)
      trigger :after, context, path, rel_path
      if context.layout
        layout_path = "#{root}/#{context.layout}"
        trigger :before, context, layout_path, context.layout
        template = Tilt.new layout_path
        layout = template.render(context) { view }
        trigger :after, context, layout_path, context.layout
      end
      puts view.inspect
      puts layout.inspect
    end
  end
  
  def trigger(type, context, path, rel_path)
    dir = File.dirname path
    begin
      callbacks = controllers[dir]
      if callbacks
        blocks = callbacks.send(type, nil)
        blocks += callbacks.send(type, rel_path)
        blocks += callbacks.send(type, File.basename(rel_path))
        blocks.each do |block|
          if type == :helpers
            context.class.class_eval &block
          else
            context.instance_eval &block
          end
        end
      end
      dir = File.expand_path('../', dir)
    end while dir != root && dir != '/'
  end
  
  class Context
    class Controller
      
      def after(view=nil, &block)
        @after ||= {}
        @after[view] ||= []
        if block
          @after[view] << block
        else
          @after[view]
        end
      end
      
      def before(view=nil, &block)
        @before ||= {}
        @before[view] ||= []
        if block
          @before[view] << block
        else
          @before[view]
        end
      end
      
      def helpers(view=nil, &block)
        @helpers ||= {}
        @helpers[view] ||= []
        if block
          @helpers[view] << block
        else
          @helpers[view]
        end
      end
    end
    
    class Render
      attr_reader :ignore, :path, :layout, :view
      
      def initialize(rel_path)
        @view = rel_path
      end
    end
  end
end