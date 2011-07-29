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
      @blocks.each do |(path, block)|
        dir = File.dirname(path) if path
        if path.nil? || @stasis.path[0..dir.length-1] == dir
          @stasis.action.class.class_eval(&block)
        end
      end
    end

    # This method is bound to all controllers. Stores a block in the `@blocks` `Array`.
    def helpers(&block)
      if block
        @blocks << [ @stasis.path, block ]
      end
    end
  end
end