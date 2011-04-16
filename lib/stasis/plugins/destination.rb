class Stasis
  class Destination < Plugin

    action_method :destination => :destination_action
    before_render :before_render
    controller_method :destination => :destination_controller

    def before_render(controller, action, path)
      if @destinations && match = match_key?(@destinations, path)[0]
        action._[:destination] = match
      else
        action._[:destination] = nil
      end
      [ controller, action, path ]
    end

    def destination_action(action, path)
      @destinations ||= {}
      @destinations[action._[:path]] = path
      before_render(nil, action, action._[:path])
    end

    def destination_controller(controller, hash)
      @destinations ||= {}
      @destinations.merge! hash.inject({}) { |hash, (key, value)|
        hash[controller.resolve(key)] = value
        hash
      }
    end
  end
end