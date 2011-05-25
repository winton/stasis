class Stasis
  class Before < Plugin

    before_all :before_all
    before_render :before_render
    controller_method :before
    priority 1

    def initialize
      @blocks = {}
    end

    # This method is bound to all controllers. Stores a block in the `@blocks` `Hash`,
    # where the key is a path and the value is an `Array` of blocks.
    def before(controller, path=nil, &block)
      if block
        path = controller._resolve(path, true)
        @blocks[path] ||= []
        @blocks[path] << block
      else
        @blocks[path] || []
      end
    end

    # This event triggers before all files render. When a `before` call receives a path
    # that does not exist, we want to create that file dynamically. This method adds
    # those dynamic paths to the `paths` `Array`.
    def before_all(controller, controllers, paths)
      new_paths = (@blocks || {}).keys.select do |path|
        path.is_a?(::String)
      end
      [ controller, controllers, (paths + new_paths).uniq ]
    end

    # This event triggers before each file renders through Stasis. It finds matching
    # blocks for the `path` and evaluates those blocks using the `action` as a scope.
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

    # Lets the `action` know that we want to capture any render that occurs within the
    # `block`.
    def capture_render(action, &block)
      old = action._[:capture_render]
      action._[:capture_render] = true
      yield
      action._[:capture_render] = old
    end
  end
end