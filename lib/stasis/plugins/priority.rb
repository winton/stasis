class Stasis
  class Priority < Plugin

    before_all :before_all
    controller_method :priority
    priority 2

    def initialize
      @@priorities ||= {}
    end

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

    def priority(controller, hash)
      hash = hash.inject({}) do |hash, (key, value)|
        key = controller.resolve(key)
        hash[key] = value if key
        hash
      end
      @@priorities.merge!(hash)
    end
  end
end