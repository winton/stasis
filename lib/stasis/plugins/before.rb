class Stasis
  class Before < Plugin

    before_all :before_all
    before_render :before_render
    controller_method :before
    priority 1

    def before(controller, path=nil, &block)
      @blocks ||= {}
      if block
        path = controller.resolve(path, true)
        @blocks[path] ||= []
        @blocks[path] << block
      else
        @blocks[path] || []
      end
    end

    def before_all(controller, controllers, paths)
      new_paths = (@blocks || {}).keys.select do |path|
        path.is_a?(::String)
      end
      [ controller, controllers, (paths + new_paths).uniq ]
    end

    def before_render(controller, action, path)
      if @blocks && matches = match_key?(@blocks, path)
        action._[:path] = path
        matches.flatten.each do |block|
          action._[:capture_render] = true
          action.instance_eval(&block)
          action._.delete(:capture_render)
        end
        action._[:path] = nil
      end
      [ controller, action, path ]
    end
  end
end