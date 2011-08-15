class Stasis
  class Ignore < Plugin

    before_render :before_render
    controller_method :ignore

    def initialize(stasis)
      @stasis = stasis
      @ignore = {}
    end

    # This event triggers before each file renders. Rejects any `paths` that are included
    # in the `@ignore` `Array`.
    def before_render
      matches = _match_key?(@ignore, @stasis.path)
      matches.each do |group|
        group.each do |path|
          @stasis.path = nil if _within?(path)
        end
      end
    end

    # This method is bound to all controllers. Adds an `Array` of paths to the `@ignore`
    # `Array`.
    def ignore(*array)
      array.each do |path|
        path = @stasis.controller._resolve(path)
        if path
          @ignore[path] ||= []
          @ignore[path] << @stasis.path
        end
      end
    end
  end
end