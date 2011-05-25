class Stasis
  class Layout < Plugin

    action_method :layout => :layout_action
    before_render :before_render
    controller_method :layout => :layout_controller

    def initialize
      @layouts = {}
    end

    # This event triggers before each file renders through Stasis. It sets the `action`
    # layout from the matching layout for `path`.
    def before_render(controller, action, path)
      if @layouts && match = _match_key?(@layouts, path)[0]
        action._[:layout] = match
      else
        action._[:layout] = nil
      end
      [ controller, action, path ]
    end

    # This method is bound to all actions. Add the resolved path to `@layouts` and set
    # the `action` layout.
    def layout_action(action, path)
      if p = action._[:controller]._resolve(path)
        @layouts[action._[:path]] = p
        before_render(nil, action, action._[:path])
      end
    end

    # This method is bound to all controllers. If it receives a `String` as a parameter,
    # use that layout for all paths. Otherwise, it receives a `Hash` with the key being
    # the `path` and the value being the layout to use for that `path`.
    def layout_controller(controller, hash_or_string)
      if hash_or_string.is_a?(::String)
        hash = {}
        hash[/.*/] = hash_or_string
      else
        hash = hash_or_string
      end
      @layouts.merge! hash.inject({}) { |hash, (key, value)|
        key = controller._resolve(key)
        hash[key] = controller._resolve(value)
        controller.ignore(hash[key])
        hash
      }
    end
  end
end