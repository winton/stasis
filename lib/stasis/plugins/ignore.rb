class Stasis
  class Ignore < Plugin

    before_all :before_all
    controller_method :ignore

    def before_all(controller, controllers, paths)
      [ controller, controllers, paths - @ignore ]
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