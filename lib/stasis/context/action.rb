class Stasis
  class Context
    class Action

      attr_reader :_
      include Plugin::Helpers

      def initialize(plugins)
        @_ = { :plugins => plugins }
        _bind_plugins(:action_method)
      end
    end
  end
end