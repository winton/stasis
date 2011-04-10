class Stasis
  class Before < Plugin

    before_render :before_render
    controller_method :before
    priority 1

    def before(controller, path=nil, &block)
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

    def before_render(controller, action, path)
      if @blocks[path]
        @blocks[path].each do |block|
          action._[:path] = path
          action.instance_eval(&block)
          action._[:path] = nil
        end
      end
      [ controller, action, path ]
    end
  end
end