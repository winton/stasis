class Stasis
  class Plugin
    class <<self

      # The class variable is named `@_` so that there is little likelihood that a
      # user-defined variable will conflict.
      attr_accessor :_

      # Here we define class methods that only exist to store method names. Each method
      # can accept either an `Array` or a `Hash` of method names. `Hash` parameters only
      # make sense when used with bind methods (`action_method` and `controller_method`),
      # i.e. `{ :bind_as_method => :real_method }`. `Array` parameters are stored as a
      # `Hash` for continuity.
      %w(
        action_method
        after_all
        after_render
        before_all
        before_render
        controller_method
      ).each do |method|
        method = method.to_sym
        # Define method on the `Plugin` class.
        define_method(method) do |*methods|
          # Set defaults on the `_` class variable.
          self._ ||= { :methods => {}, :priority => 0 }
          self._[:methods][method] ||= {}
          # If passing a `Hash`...
          if methods[0].is_a?(::Hash)
            self._[:methods][method].merge!(methods[0])
          # If passing an `Array`...
          else
            # Generate `Hash` from `Array`.
            methods = methods.inject({}) do |hash, m|
              hash[m] = m
              hash
            end
            self._[:methods][method].merge!(methods)
          end
        end
      end

      # Class method to set priority on the `Plugin`.
      def priority(number)
        self._ ||= { :methods => {}, :priority => 0 }
        self._[:priority] = number
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