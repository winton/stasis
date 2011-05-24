class Stasis
  class Before < Plugin

    before_all :before_all
    before_render :before_render
    controller_method :before
    priority 1

    def initialize
      @blocks = {}
    end

    def before(controller, path=nil, &block)
      if block
        path = controller._resolve(path, true)
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
      if @blocks && matches = _match_key?(@blocks, path)
        action._[:path] = path
        matches.flatten.each do |block|
          capture_render(action) do
            action.instance_eval(&block)
          end
        end
        action._[:path] = nil
      end
      [ controller, action, path ]
    end

    def capture_render(action, &block)
      old = action._[:capture_render]
      action._[:capture_render] = true
      yield
      action._[:capture_render] = old
    end
  end
end