class Stasis
  class Destination < Plugin

    before_render :before_render
    controller_method :destination

    def before_render(controller, action, path)
      if @destinations && @destinations[path]
        action.instance_eval <<-RUBY
          @destination = #{@destinations[path]}
        RUBY
      end
      [ controller, action, path ]
    end

    def destination(controller, hash)
      @destinations ||= {}
      @destinations.merge! hash.inject({}) { |hash, (key, value)|
        hash[key] = controller.resolve(value)
        hash
      }
    end
  end
end