class Stasis
  class Before < Plugin

    before_render :before_render
    controller_method :before

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
          action.instance_eval(&block)
        end
      end
      [ controller, action, path ]
    end
  end
end