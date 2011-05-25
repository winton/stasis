class Stasis
  class Priority < Plugin

    after_all :after_all
    before_all :before_all
    controller_method :priority
    priority 2

    def initialize
      @@priorities ||= {}
    end

    # This event triggers after all files render through Stasis. Reset `@@priorities`.
    def after_all(controller, controllers, paths)
      @@priorities = {}
      [ controller, controllers, paths ]
    end

    # This event triggers before all files render through Stasis. Collect matching
    # `paths` and sort those `paths` by priority.
    def before_all(controller, controllers, paths)
      paths.collect! do |path|
        priority = 0
        @@priorities.each do |key, value|
          if (key.is_a?(::Regexp) && path =~ key) || key == path
            priority = value
          end
        end
        [ path, priority ]
      end
      paths.sort! { |a, b| b[1] <=> a[1] }
      paths.collect! { |(path, priority)| path }
      @@priorities = {}
      [ controller, controllers, paths ]
    end

    # This method is bound to all controllers. Stores a priority integer in the
    # `@@priorities` `Hash`, where the key is a path and the value is the priority.
    def priority(controller, hash)
      hash = hash.inject({}) do |hash, (key, value)|
        key = controller._resolve(key)
        hash[key] = value if key
        hash
      end
      @@priorities.merge!(hash)
    end
  end
end