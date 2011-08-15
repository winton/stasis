class Stasis
  class Priority < Plugin

    after_all :after_all
    before_all :before_all
    controller_method :priority
    priority 2

    def initialize(stasis)
      @stasis = stasis
      @priorities = {}
    end

    # This event triggers before all files render through Stasis. Collect matching
    # `paths` and sort those `paths` by priority.
    def before_all
      @stasis.paths.collect! do |path|
        priority = 0
        matches = _match_key?(@priorities, path)
        matches.each do |(within, value)|
          priority = value if _within?(within, path)
        end
        [ path, priority ]
      end
      @stasis.paths.sort! { |a, b| b[1] <=> a[1] }
      @stasis.paths.collect! { |(path, priority)| path }
    end

    # This method is bound to all controllers. Stores a priority integer in the
    # `@@priorities` `Hash`, where the key is a path and the value is the priority.
    def priority(hash)
      hash = hash.inject({}) do |hash, (key, value)|
        key = @stasis.controller._resolve(key)
        hash[key] = [ @stasis.path, value ] if key
        hash
      end
      @priorities.merge!(hash)
    end
  end
end