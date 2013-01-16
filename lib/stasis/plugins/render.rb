require 'tilt'

class Stasis
  class Render < Plugin

    action_method :render

    def initialize(stasis)
      @stasis = stasis
    end

    # This method is bound to all actions.
    def render(path_or_options={}, options={}, &block)
      if path_or_options.is_a?(::String)
        options[:path] = path_or_options
      else
        options.merge!(path_or_options)
      end

      callback = options[:callback]
      locals = options[:locals]
      path = options[:path]
      ext = File.extname(path.to_s)[1..-1]
      scope = options[:scope]
      text = options[:text]
      template_options = Options.get_template_option(ext).merge( options[:template] || {} )

      if @stasis.controller
        path = @stasis.controller._resolve(path)
      end
      
      output =
        if text
          text
        elsif path && File.file?(path)
          unless callback == false
            # Trigger all plugin `before_render` events.
            temporary_path(path) do
              @stasis.trigger(:before_render)
            end
          end

          output =
            if Tilt.mappings.keys.include?(ext)
              scope = options[:scope] ||= @stasis.action
              tilt = Tilt.new(path, nil, template_options)
              if block_given?
                tilt.render(scope, locals, &block)
              else
                tilt.render(scope, locals) { nil }
              end
            else
              File.read(path)
            end

          unless callback == false
            # Trigger all plugin `after_render` events.
            temporary_path(path) do
              @stasis.trigger(:after_render)
            end
          end

          output
        end
      
      output
    end

    private

    # Temporarily set `Stasis#path`.
    def temporary_path(path, &block)
      @stasis.path, old_path = path, @stasis.path
      yield
      @stasis.path = old_path
    end
  end
end
