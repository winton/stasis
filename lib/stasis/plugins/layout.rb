class Stasis
  class Layout < Plugin

    action_method :layout => :layout_action
    before_render :before_render
    controller_method :layout => :layout_controller

    def before_render(controller, action, path)
      if @layouts && match = match_key?(@layouts, path)[0]
        action._[:layout] = match
      else
        action._[:layout] = nil
      end
      [ controller, action, path ]
    end

    def layout_action(action, path)
      @layouts ||= {}
      if p = action._[:controller].resolve(path)
        @layouts[action._[:path]] = p
        before_render(nil, action, action._[:path])
      end
    end

    def layout_controller(controller, hash_or_string)
      if hash_or_string.is_a?(::String)
        hash = {}
        hash[/.*/] = hash_or_string
      else
        hash = hash_or_string
      end
      @layouts ||= {}
      @layouts.merge! hash.inject({}) { |hash, (key, value)|
        hash[key] = controller.resolve(value)
        controller.ignore(hash[key])
        hash
      }
    end
  end
end