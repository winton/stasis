class Stasis
  class Priority < Plugin

    before_all :before_all
    controller_method :priority

    def before_all(controller, controllers, paths)
      priorities = (@priorities || []).sort { |a, b| b[1] <=> a[1] }
      priorities = priorities.inject({}) do |hash, (path_or_regexp, priority)|
        paths.each do |path|
          if path_or_regexp.is_a?(::Regexp) && path =~ path_or_regexp
            hash[path] = priority
          elsif path == path_or_regexp
            hash[path] = priority
          end
        end
        hash
      end
      priorities.merge! (paths - priorities.keys).inject({}) { |hash, path|
        hash[path] = 0
        hash
      }
      priorities = priorities.to_a.sort { |a, b| b[1] <=> a[1] }
      paths = priorities.collect { |(path, priority)| path }
      [ controller, controllers, paths ]
    end

    def priority(controller, hash)
      @priorities ||= []
      @priorities += hash.to_a.collect do |pair|
        pair[0] = controller.resolve(pair[0])
        pair[0] ? pair : nil
      end
      @priorities.compact!
    end
  end
end