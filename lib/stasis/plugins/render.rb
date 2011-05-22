require 'tilt'

class Stasis
  class Render < Plugin

    action_method :render

    def render(action, path_or_options={}, options={}, &block)
      if path_or_options.is_a?(::String)
        options[:path] = path_or_options
      else
        options.merge!(path_or_options)
      end

      locals = options[:locals]
      path = options[:path]
      scope = options[:scope]
      text = options[:text]
      
      output =
        if text
          text
        elsif Tilt.mappings.keys.include?(File.extname(path)[1..-1])
          scope = options[:scope] ||= action
          if action._[:controller]
            path = action._[:controller]._resolve(path)
          end
          Tilt.new(path).render(scope, locals, &block)
        else
          File.read(path)
        end
      if action._[:capture_render]
        action._[:render] = output
      end
      output
    end
  end
end