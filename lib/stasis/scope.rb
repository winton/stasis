class Stasis
  class Scope

    # `Stasis`.
    attr_accessor :_stasis

    # Plugins use the `controller_method` and `action_method` class methods to bind
    # plugin methods to a scope instance. This method does the binding.
    def _bind_plugin(plugin, type)
      _each_plugin_method(plugin, type) do |plugin, method, real_method|
        self.instance_eval <<-EVAL
          # Define a method on `self` (the `Scope` instance).
          def #{method}(*args, &block)
            # Find the plugin.
            plugin = self._stasis.plugins.detect do |plugin|
              plugin.to_s == "#{plugin.to_s}"
            end
            # Pass parameters to the method on the plugin.
            plugin.send(:#{real_method}, *args, &block)
          end
        EVAL
      end
    end

    def _each_plugin_method(plugin, type, &block)
      # Retrieve plugin `methods`: a `Hash` whose keys are the method name to bind to
      # `self`, and whose values are the method name on the `Plugin` class we are
      # binding from.
      methods = plugin.class._methods[type] || {}
      methods.each do |method, real_method|
        yield(plugin, method, real_method)
      end
    end

    def _each_plugins_method(type, &block)
      # For each plugin...
      _stasis.plugins.each do |plugin|
        _each_plugin_method(plugin, type, &block)
      end
    end

    # Using all `Plugin` instances of a certain priority, call methods of a certain type.
    def _send_to_plugin(priority, type)
      _each_plugins_method(type) do |plugin, method, real_method|
        # If priority matches and plugin responds to method...
        if plugin.class._priority == priority && plugin.respond_to?(real_method)
          # Call plugin method.
          plugin.send(real_method)
        end
      end
      args
    end
  end
end