class Stasis
  class Plugin
    module Helpers

      def _bind_plugins(type)
        _[:plugins].each do |plugin|
          methods = plugin.class._[:methods][type]
          (methods || []).each do |method|
            self.instance_eval <<-EVAL
              def #{method}(*args, &block)
                _send_to_plugin_by_method(#{method.inspect}, *args, &block)
              end
            EVAL
          end
        end
      end

      def _send_to_plugin_by_method(method, *args, &block)
        args = [ self ] + args
        _[:plugins].each do |plugin|
          if plugin.respond_to?(method)
            return plugin.send(method, *args, &block)
          end
        end
      end

      def _send_to_plugin_by_type(type, *args, &block)
        arg = [ @_controller, self ].compact + args
        _[:plugins].each do |plugin|
          methods = plugin.class._[:methods][type]
          (methods || []).each do |method|
            if plugin.respond_to?(method)
              arg = plugin.send(method, *arg, &block)
            end
          end
        end
        arg
      end
    end
  end
end