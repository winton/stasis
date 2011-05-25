require 'tilt'

class Stasis
  class Render < Plugin

    action_method :render

    # This method is bound to all actions.
    def render(action, path_or_options={}, options={}, &block)
      if path_or_options.is_a?(::String)
        options[:path] = path_or_options
      else
        options.merge!(path_or_options)
      end

      callback = options[:callback]
      locals = options[:locals]
      path = options[:path]
      scope = options[:scope]
      text = options[:text]

      if action._[:controller]
        path = action._[:controller]._resolve(path)
      end
      
      output =
        if text
          text
        elsif File.file?(path)
          unless callback == false
            # Trigger all plugin `before_render` events, passing the `Action` instance
            # and the current path.
            action, path = action._[:stasis].trigger(:before_render, path, action, path)
          end

          output =
            if Tilt.mappings.keys.include?(File.extname(path)[1..-1])
              scope = options[:scope] ||= action
              Tilt.new(path).render(scope, locals, &block)
            else
              File.read(path)
            end

          unless callback == false
            # Trigger all plugin `after_render` events, passing the `Action` instance and the
            # current path.
            action, path = action._[:stasis].trigger(:after_render, path, action, path)
          end

          output
        end
      
      if action._[:capture_render]
        action._[:render] = output
      end
      
      output
    end
  end
end