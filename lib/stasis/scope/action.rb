# `Action` provides a scope for markup rendered via [Tilt][ti] and `before` blocks within
# a controller.
#
# [ti]: https://github.com/rtomayko/tilt

class Stasis
  class Action < Scope

    attr_reader :params

    def initialize(options)
      # `Hash` -- Contains two key/value pairs:
      #
      # * `path` -- Path of the view that this instance provides a scope for.
      # * `plugins` -- `Array` of `Plugin` instances.
      # * `stasis` -- A reference to the `Stasis` instance that created this `Action`.
      @_ = options

      # `Hash` -- Passed from the `params` option given to `Stasis#generate`.
      @params = options[:params]

      # Some plugins define methods to be made available to action scopes. This call
      # binds those methods.
      @_[:plugins].each do |plugin|
        _bind_plugin(plugin, :action_method)
      end
    end
  end
end