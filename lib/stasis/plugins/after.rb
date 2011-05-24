class Stasis
  class After < Plugin

    after_render :after_render
    controller_method :after
    priority 1

    def initialize
      @blocks = {}
    end

    # This method is bound to all controllers. Stores a `block` to `@blocks` using the
    # resolved path as a key.
    def after(controller, path=nil, &block)
      if block
        path = controller._resolve(path)
        return [] if path == false
        @blocks[path] ||= []
        @blocks[path] << block
      else
        @blocks[path] || []
      end
    end

    # This event triggers after any file renders through Stasis. It finds matching blocks
    # for the `path` and evaluates those blocks using the `action` as a scope.
    def after_render(controller, action, path)
      if @blocks && matches = _match_key?(@blocks, path)
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