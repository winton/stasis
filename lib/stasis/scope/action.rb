# `Action` provides a scope for markup rendered via [Tilt][ti] and `before` blocks within
# a controller.
#
# [ti]: https://github.com/rtomayko/tilt

class Stasis
  class Action < Scope

    def initialize(options)
      # `Hash` -- Contains two key/value pairs:
      #
      # * `path` -- Path of the view that this instance provides a scope for.
      # * `plugins` -- `Array` of `Plugin` instances.
      @_ = options

      # Some plugins define methods to be made available to action scopes. This call
      # binds those methods.
      _bind_plugins(:action_method)
    end
  end
end