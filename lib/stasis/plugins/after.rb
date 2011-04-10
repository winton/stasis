class Stasis
  class After < Plugin

    after_render :after_render
    controller_method :after
    priority 1

    def after(controller, path=nil, &block)
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

    def after_render(controller, action, path)
      if @blocks && @blocks[path]
        action.instance_eval(@blocks[path])
      end
      [ controller, action, path ]
    end
  end
end