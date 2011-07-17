class Stasis
  class Layout < Plugin

    action_method :layout => :layout_action
    before_render :before_render
    controller_method :layout => :layout_controller

    def initialize(stasis)
      @stasis = stasis
      @layouts = {}
    end

    # This event triggers before each file renders through Stasis. It sets the `action`
    # layout from the matching layout for `path`.
    def before_render
      if @layouts && match = _match_key?(@layouts, @stasis.path)[0]
        @stasis.action._layout = match
      else
        @stasis.action._layout = nil
      end
    end

    # This method is bound to all actions. Set the `action` layout.
    def layout_action(path)
      if p = @stasis.controller._resolve(path)
        @stasis.action._layout = p
      end
    end

    # This method is bound to all controllers. If it receives a `String` as a parameter,
    # use that layout for all paths. Otherwise, it receives a `Hash` with the key being
    # the `path` and the value being the layout to use for that `path`.
    def layout_controller(hash_or_string)
      if hash_or_string.is_a?(::String)
        hash = {}
        hash[/.*/] = hash_or_string
      else
        hash = hash_or_string
      end
      @layouts.merge! hash.inject({}) { |hash, (key, value)|
        key = @stasis.controller._resolve(key)
        hash[key] = @stasis.controller._resolve(value)
        @stasis.controller.ignore(hash[key])
        hash
      }
    end
  end
end