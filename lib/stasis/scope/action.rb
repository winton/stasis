# `Action` provides a scope for markup rendered via [Tilt][ti] and `before` blocks within
# a controller.
#
# [ti]: https://github.com/rtomayko/tilt

class Stasis
  class Action < Scope

    # `String` -- Path to the layout for this action.
    attr_accessor :_layout

    # `String` -- If present, render this path instead of the default.
    attr_accessor :_render

    # `Hash` -- Parameters to be made available to the scope, usually through
    # `Stasis::Server`.
    attr_accessor :params

    def initialize(stasis, options={})
      @_stasis = stasis
      @params = options[:params] || {}

      @params = @params.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end

      # Some plugins define methods to be made available to action scopes. This call
      # binds those methods.
      @_stasis.plugins.each do |plugin|
        _bind_plugin(plugin, :action_method)
      end
    end
  end
end