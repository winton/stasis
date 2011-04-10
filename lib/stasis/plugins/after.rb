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
      if @blocks && matches = match_key?(@blocks, path)
        action._[:path] = path
        matches.flatten.each do |block|
          action.instance_eval(&block)
        end
        action._[:path] = nil
      end
      [ controller, action, path ]
    end
  end
end