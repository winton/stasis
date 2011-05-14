# `Context::Action` provides a scope for markup rendered via [Tilt][ti] and `before`
# blocks within a controller.
#
# [ti]: https://github.com/rtomayko/tilt

class Stasis
  class Context
    class Action

      # `Hash` -- Contains two key/value pairs:
      #
      # * `path` -- Path of the view that this instance provides a scope for.
      # * `plugins` -- `Array` of `Plugin` instances.
      #
      # The class variable is named `@_` so that there is little likelihood that a
      # user-defined variable will conflict.
      attr_reader :_

      include Plugin::Helpers

      def initialize(options)
        @_ = options

        # Some plugins define methods to be made available to action contexts. This call
        # binds those methods.
        _bind_plugins(:action_method)
      end
    end
  end
end