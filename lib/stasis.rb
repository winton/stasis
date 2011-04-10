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
  
  attr_reader :controllers, :plugins, :root
  
  def initialize(root)
    @root = root
    @plugins = self.class.constants.collect { |klass|
      klass = klass.to_s
      unless %w(Context Gems Plugin).include?(klass)
        eval("::Stasis::#{klass}").new
      end
    }.compact
    @plugins.sort! { |a, b| a.class._[:priority] <=> b.class._[:priority] }
    @controllers = Dir["#{root}/**/controller.rb"].inject({}) do |hash, path|
      context = Context::Controller.new(path, @plugins, root)
      hash[context._[:dir]] = context
      hash
    end
  end
  
  def generate(*paths)
    paths = paths.collect { |p| Dir["#{root}/#{p}"] }.flatten
    paths.reject! { |p| File.basename(p) == 'controller.rb' }
    @controllers, paths = trigger(:before_all, '*', controllers, paths)
    paths.each do |path|
      @action = Context::Action.new(@plugins)
      trigger(:before_render, path, @action, path)
      if @action._[:layout]
        view = @action.render(@action._[:layout]) { @action.render(path) }
      else
        view = @action.render(path)
      end
      trigger(:after_render, path, @action, path)
      puts @action._[:layout].inspect
      puts view.inspect
    end
  end

  def each_directory(path, &block)
    dir = File.dirname(path)
    while dir != File.expand_path('../', root) && dir != '/'
      yield(dir)
      dir = File.expand_path('../', dir)
    end
  end

  def trigger(type, path, *args, &block)
    if path == '*'
      controllers.values.each do |controller|
        args = controller._send_to_plugin_by_type(type, *args, &block)
      end
    else
      each_directory(path) do |dir|
        if controller = controllers[dir]
          @action._[:controller] = controller
          args = controller._send_to_plugin_by_type(type, *args, &block)
        end
      end
      @action._[:controller] = nil
    end
    args[1..-1]
  end
end