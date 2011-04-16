class Stasis
  class Ignore < Plugin

    before_all :before_all
    controller_method :ignore

    def before_all(controller, controllers, paths)
      (@ignore || []).each do |ignore|
        paths.reject! do |path|
          if ignore.is_a?(::String)
            ignore == path
          elsif ignore.is_a?(::Regexp)
            ignore =~ path
          else
            false
          end
        end
      end
      [ controller, controllers, paths ]
    end

    def ignore(controller, *array)
      @ignore ||= []
      @ignore += array.collect do |path|
        path = controller.resolve(path)
        path ? path : nil
      end
      @ignore.compact!
    end
  end
end