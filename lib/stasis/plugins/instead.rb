class Stasis
  class Instead < Plugin

    action_method :instead

    def initialize(stasis)
      @_stasis = stasis
    end

    # This method is bound to all actions.
    def instead(string)
      @_stasis.action._render = string
    end
  end
end