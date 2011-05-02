class Stasis
  class Context
    class Action

      attr_reader :_
      include Plugin::Helpers

      def initialize(options)
        @_ = options
        _bind_plugins(:action_method)
      end
    end
  end
end