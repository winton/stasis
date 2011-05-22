class Stasis
  class Plugin
    class <<self

      attr_accessor :_

      %w(
        action_method
        after_all
        after_render
        before_all
        before_render
        controller_method
      ).each do |method|
        method = method.to_sym
        define_method(method) do |*methods|
          self._ ||= { :methods => {}, :priority => 0 }
          self._[:methods][method] ||= {}
          if methods[0].is_a?(::Hash)
            self._[:methods][method].merge!(methods[0])
          else
            methods = methods.inject({}) do |hash, m|
              hash[m] = m
              hash
            end
            self._[:methods][method].merge!(methods)
          end
        end
      end

      def priority(number)
        self._ ||= { :methods => {}, :priority => 0 }
        self._[:priority] = number
      end
    end

    private

    def match_key?(hash, match_key)
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