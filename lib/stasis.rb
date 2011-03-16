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
      context = Context::Controller.new path, root
      hash[context._stasis[:dir]] = context
      hash
    end
  end
  
  def generate(*paths)
    paths = paths.collect { |p| Dir["#{root}/#{p}"] }.flatten
    priorities = @controllers.values.inject([]) do |array, context|
      array += context._stasis[:priority] || []
    end
    priorities.sort! { |a, b| b[1] <=> a[1] }
    priorities = priorities.inject({}) do |hash, (path_or_regexp, priority)|
      paths.each do |path|
        if path_or_regexp.is_a?(::Regexp) && path =~ path_or_regexp
          hash[path] = priority
        elsif path == path_or_regexp
          hash[path] = priority
        end
      end
      hash
    end
    priorities.merge! (paths - priorities.keys).inject({}) { |hash, path|
      hash[path] = 0
      hash
    }
    priorities = priorities.to_a.sort { |a, b| b[1] <=> a[1] }
    paths = priorities.collect { |(path, priority)| path }
    paths -= @controllers.values.inject([]) { |array, context|
      array += context._stasis[:ignore] || []
    }
    paths.each do |path|
      next unless File.file?(path)
      next unless Tilt.mappings.keys.include?(File.extname(path)[1..-1])
      rel_path = path[root.length+1..-1]
      context = Context::Render.new rel_path
      trigger :helpers, context, path
      trigger :before, context, path
      next unless context.destination
      template = Tilt.new path
      view = template.render(context)
      trigger :after, context, path
      if context.layout
        layout_path = "#{root}/#{context.layout}"
        trigger :before, context, layout_path
        template = Tilt.new layout_path
        layout = template.render(context) { view }
        trigger :after, context, layout_path
      end
      puts view.inspect
      puts layout.inspect
    end
  end
  
  def trigger(type, context, path)
    dir = File.dirname path
    while dir != File.expand_path('../', root) && dir != '/'
      callbacks = controllers[dir]
      if callbacks
        blocks = callbacks.send(type, nil)
        blocks += callbacks.send(type, path)
        blocks.each do |block|
          if type == :helpers
            context.class.class_eval &block
          else
            context.instance_eval &block
          end
        end
      end
      dir = File.expand_path('../', dir)
    end
  end
  
  class Context
    class Controller
      
      attr_reader :_stasis
      
      def initialize(path, root)
        dir = File.dirname path
        rel_dir = File.dirname(path)[root.length+1..-1]
        @_stasis = {
          :dir => dir,
          :path => path,
          :rel_dir => rel_dir,
          :resolve => lambda { |view|
            if view.nil?
              nil
            elsif view.is_a?(Regexp)
              view
            elsif File.file?(p = "#{root}#{rel_dir}/#{view}")
              p
            elsif File.file?(p = "#{root}/#{view}")
              p
            else
              false
            end
          },
          :root => root
        }
        instance_eval File.read(path), path
      end
      
      %w(after before helpers).each do |type|
        class_eval <<-EVAL
          def #{type}(view=nil, &block)
            @_stasis[:#{type}] ||= {}
            if block
              view = @_stasis[:resolve].call view
              return [] if view == false
              @_stasis[:#{type}][view] ||= []
              @_stasis[:#{type}][view] << block
            else
              @_stasis[:#{type}][view] || []
            end
          end
        EVAL
      end
      
      def ignore(*array)
        @_stasis[:ignore] ||= []
        @_stasis[:ignore] += array.collect do |path|
          path = @_stasis[:resolve].call path
          path ? path : nil
        end
        @_stasis[:ignore].compact!
      end
      
      def priority(hash)
        @_stasis[:priority] ||= []
        @_stasis[:priority] += hash.to_a.collect do |pair|
          pair[0] = @_stasis[:resolve].call pair[0]
          pair[0] ? pair : nil
        end
        @_stasis[:priority].compact!
      end
    end
    
    class Render
      attr_reader :destination, :layout, :source
      
      def initialize(rel_path)
        @destination = rel_path.split('.')[0..-2].join('.')
        @source = rel_path
      end
    end
  end
end