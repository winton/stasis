class Stasis
  class Layout < Plugin

    action_method :layout => :layout_action
    before_render :before_render
    controller_method :layout => :layout_controller
    reset :reset

    def initialize(stasis)
      @stasis = stasis
      reset
    end

    # This event triggers before each file renders through Stasis. It sets the `action`
    # layout from the matching layout for `path`.
    def before_render
      return unless @stasis.path
      @stasis.action._layout = nil
      matches = _match_key?(@layouts, @stasis.path)
      # Non-HTML extensions.
      non_html = %w(sass scss less builder coffee yajl)
      # Find matching layout.
      [ :same, :similar ].each do |type|
        matches.each do |(within, layout, non_specific)|
          layout_ext = File.extname(layout)[1..-1]
          path_ext = File.extname(@stasis.path)[1..-1]

          match =
            case type
            # Same extension?
            when :same then
              layout_ext == path_ext
            # Similar extension?
            when :similar then
              non_html.include?(layout_ext) == non_html.include?(path_ext)
            end

          # Set layout
          if _within?(within) && match
            @stasis.action._layout = layout
          end
        end
        break if @stasis.action._layout
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

    # This event resets all instance variables.
    def reset
      @layouts = {}
    end
  end
end