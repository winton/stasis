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
      return unless @stasis.path
      @stasis.action._layout = nil
      matches = _match_key?(@layouts, @stasis.path)
      # Find matching layout with same extension.
      matches.each do |(within, layout, non_specific)|
        if _within?(within) && File.extname(layout) == File.extname(@stasis.path)
          @stasis.action._layout = layout
        end
      end
      # If layout not found, try again without extension requirement for specific layout
      # definitions only.
      unless @stasis.action._layout
        matches.each do |(within, layout, non_specific)|
          if _within?(within) && !non_specific
            @stasis.action._layout = layout
          end
        end
      end
    end

    # This method is bound to all actions. Set the `action` layout.
    def layout_action(path)
      if path = @stasis.controller._resolve(path)
        @stasis.action._layout = path
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
      @layouts.merge! hash.inject({}) { |hash, (path, layout)|
        path = @stasis.controller._resolve(path)
        layout = @stasis.controller._resolve(layout)
        if layout
          hash[path] = [ @stasis.path, layout, path == /.*/ ]
          @stasis.controller.ignore(layout)
        end
        hash
      }
    end
  end
end