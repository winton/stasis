class Stasis
  class Scope

    # The class variable is named `@_` so that there is little likelihood that a
    # user-defined variable will conflict.
    attr_reader :_

    # Plugins use the `controller_method` and `action_method` class methods to bind
    # plugin methods to a scope instance. This method does the binding.
    def _bind_plugin(plugin, type)
      _each_plugin_method(plugin, type) do |plugin, method, real_method|
        self.instance_eval <<-EVAL
          def #{method}(*args, &block)
            # Define a method on `self` (the `Scope` instance).
            args = [ self ] + args
            # Find the plugin.
            plugin = self._[:plugins].detect do |plugin|
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
      methods = plugin.class._[:methods][type] || {}
      methods.each do |method, real_method|
        yield(plugin, method, real_method)
      end
    end

    def _each_plugins_method(type, &block)
      # For each plugin...
      _[:plugins].each do |plugin|
        _each_plugin_method(plugin, type, &block)
      end
    end

    # Using all `Plugin` instances of a certain priority, grab methods of a certain
    # `type` and send the arguments to those methods.
    def _send_to_plugin(priority, type, *args, &block)
      _each_plugins_method(type) do |plugin, method, real_method|
        # If priority matches and plugin responds to method...
        if plugin.class._[:priority] == priority && plugin.respond_to?(real_method)
          # Add `Scope` instance as first parameter.
          args = [ self ] + args
          # Send arguments to plugin method.
          args = plugin.send(real_method, *args, &block)
          # Remove `Scope` instance as first parameter.
          args = args[1..-1]
        end
      end
      args
    end
  end
end