class Stasis
  class Instead < Plugin

    action_method :instead

    # This method is bound to all actions.
    def instead(action, string)
      action._[:render] = string
    end
  end
end