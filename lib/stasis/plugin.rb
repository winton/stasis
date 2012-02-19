class Stasis
  class Plugin
    class <<self

      # `Hash` -- Keys are the "bind as" method names and values are the actual method
      # names on the `Plugin` instance.
      attr_accessor :_methods

      # `Fixnum` -- The execution priority for this plugin (defaults to 0).
      def _priority; @priority || 0; end

      # The methods in this `Array` essentially all take the same kind of parameters.
      # Either a `Hash` or an `Array` of method names. No matter what, the input is
      # converted to a `Hash` (see `_methods`).
      %w(
        action_method
        after_all
        after_render
        before_all
        before_render
        controller_method
        reset
      ).each do |method|
        method = method.to_sym
        # Define method on the `Plugin` class.
        define_method(method) do |*methods|
          # Set defaults on the `_` class variable.
          self._methods ||= {}
          self._methods[method] ||= {}
          # If passing a `Hash`...
          if methods[0].is_a?(::Hash)
            self._methods[method].merge!(methods[0])
          # If passing an `Array`...
          else
            # Generate `Hash` from `Array`.
            methods = methods.inject({}) do |hash, m|
              hash[m] = m
              hash
            end
            self._methods[method].merge!(methods)
          end
        end
      end

      # Class method to set priority on the `Plugin`.
      def priority(number)
        @priority = number
      end
    end

    # Helper method provided for built-in Stasis plugins. Returns a boolean value denoting
    # whether or not a path is within another path.
    def _within?(within_path, path=@stasis.path)
      if within_path && path
        dir = File.dirname(within_path)
        path[0..dir.length-1] == dir
      else
        true
      end
    end

    # Helper method provided for built-in Stasis plugins. Returns an `Array` of values
    # of a `Hash` whose keys are `nil`, a literal match, or a pattern match.
    def _match_key?(hash, match_key)
      hash.inject([]) do |array, (key, value)|
        if key.nil?
          array << value
        elsif key.is_a?(::String) && key == match_key
          array << value
        elsif key.is_a?(::Regexp) && key =~ match_key
          array << value
        end
        array
      end
    end
  end
end
