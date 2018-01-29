class Stasis
  class After < Plugin

    after_all :after_all
    controller_method :after
    priority 1
    reset :reset

    def initialize(stasis)
      @stasis = stasis
      reset
    end

    # Add a simple hook after everything's done.
    def after(&block)
      @blocks << block
    end

    def after_all
      @blocks.each { |b| @stasis.action.instance_eval(&b) }
    end

    def reset
      @blocks = []
    end
  end
end
