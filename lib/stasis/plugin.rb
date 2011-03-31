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
        class_eval <<-EVAL, __FILE__, __LINE__ + 1
          def #{method}(*methods)
            self._ ||= { :methods => {} }
            self._[:methods][:#{method}] ||= []
            self._[:methods][:#{method}] += methods
          end
        EVAL
      end
    end
  end
end