class Stasis
  class Instead < Plugin

    action_method :instead

    # This method is bound to all actions.
    def instead(string)
      action._render = string
    end
  end
end