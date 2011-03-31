class Stasis
  class Context
    class Action

      attr_reader :_
      include Plugin::Helpers

      def initialize(plugins)
        @_ = { :plugins => plugins }
      end
    end
  end
end