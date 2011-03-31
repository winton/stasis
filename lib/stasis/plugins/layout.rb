class Stasis
  class Layout < Plugin

    before_render :before_render
    controller_method :layout

    def before_render(controller, action, path)
      if @layouts && @layouts[path]
        unless action.respond_to?(:layout)
          action.class.send(:attr_reader, :layout)
        end
        action.instance_eval <<-RUBY
          @layout = #{@layouts[path].inspect}
        RUBY
      end
      [ controller, action, path ]
    end

    def layout(controller, hash_or_string)
      if hash_or_string.is_a?(::String)
        hash = {}
        hash[/.*/] = hash_or_string
      else
        hash = hash_or_string
      end
      @layouts ||= {}
      @layouts.merge! hash.inject({}) { |hash, (key, value)|
        hash[key] = controller.resolve(value)
        hash
      }
    end
  end
end