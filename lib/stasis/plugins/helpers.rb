class Stasis
  class Helpers < Plugin

    controller_method :helpers
    before_render :bind_helpers

    def bind_helpers(controller, action, path)
      if @blocks[path]
        action.class.class_eval(@blocks[path])
      end
      [ controller, action, path ]
    end

    def helpers(controller, &block)
      @blocks ||= {}
      if block
        path = controller.resolve(path)
        return [] if path == false
        @blocks[path] ||= []
        @blocks[path] << block
      else
        @blocks[path] || []
      end
    end
  end
end