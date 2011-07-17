class Stasis
  class Ignore < Plugin

    before_all :before_all
    controller_method :ignore

    def initialize(stasis)
      @stasis = stasis
      @ignore = []
    end

    # This event triggers before all files render. Rejects any `paths` that are included
    # in the `@ignore` `Array`.
    def before_all
      @ignore.each do |ignore|
        @stasis.paths.reject! do |path|
          if ignore.is_a?(::String)
            ignore == path
          elsif ignore.is_a?(::Regexp)
            ignore =~ path
          else
            false
          end
        end
      end
    end

    # This method is bound to all controllers. Adds an `Array` of paths to the `@ignore`
    # `Array`.
    def ignore(*array)
      @ignore += array.collect do |path|
        path = @stasis.controller._resolve(path)
        path ? path : nil
      end
      @ignore.compact!
    end
  end
end