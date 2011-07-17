class Stasis
  class Helpers < Plugin

    controller_method :helpers
    before_render :before_render

    def initialize(stasis)
      @stasis = stasis
      @blocks = []
    end

    #  This event triggers before each file renders through Stasis. For each helper
    # `block`, evaluate the `block` in the scope of the `action` class.
    def before_render
      @blocks.each do |block|
        @stasis.action.class.class_eval(&block)
      end
    end

    # This method is bound to all controllers. Stores a block in the `@blocks` `Array`.
    def helpers(&block)
      if block
        @blocks << block
      end
    end
  end
end