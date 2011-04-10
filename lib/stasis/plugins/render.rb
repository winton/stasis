require 'tilt'

class Stasis
  class Render < Plugin

    action_method :render

    def render(action, path, options={}, &block)
      if Tilt.mappings.keys.include?(File.extname(path)[1..-1])
        options[:context] ||= action
        if (action._[:controller])
          Tilt.new(action._[:controller].resolve(path)).render(options[:context], options[:locals], &block)
        else
          Tilt.new(path).render(options[:context], options[:locals], &block)
        end
      else
        File.read(path)
      end
    end
  end
end