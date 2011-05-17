class Stasis
  class Helpers < Plugin

    controller_method :helpers
    before_render :bind_helpers

    def initialize
      @blocks = []
    end

    def bind_helpers(controller, action, path)
      @blocks.each do |block|
        action.class.class_eval(&block)
      end
      [ controller, action, path ]
    end

    def helpers(controller, &block)
      if block
        @blocks << block
      end
    end
  end
end