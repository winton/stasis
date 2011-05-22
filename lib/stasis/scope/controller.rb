# `Controller` provides a scope for `controller.rb` files.
#
# Stasis will still create a `Controller` instance for directories without a
# `controller.rb` file, mostly for the purposes of resolving paths and triggering plugin
# events.

class Stasis
  class Controller < Scope
    
    def initialize(dir, root)
      dir = File.expand_path(dir)
      path = "#{dir}/controller.rb"
      path = nil unless File.file?(path)

      @_ = {
        # Directory for which this controller provides a scope.
        :dir => dir,
        # Path to the `controller.rb` file (if it exists).
        :path => path,
        # A new instance of all known plugins.
        :plugins => self.class.find_plugins.collect { |klass| klass.new },
        # The root directory path of the user's project.
        :root => root
      }

      # Some plugins define methods to be made available to controller scopes. This call
      # binds those methods.
      _bind_plugins(:controller_method)

      # Evaluate `controller.rb`.
      instance_eval(File.read(path), path) if path
    end

    # Accepts three kinds of paths as the `path` parameter:
    #
    # * Absolute: `/project/path/view.haml`
    # * Relative: `view.haml`
    # * Root: `/path/view.haml`
    #
    # Returns an absolute path.
    #
    # Set the `force` parameter to `true` to return the resolved path even if no file
    # exists at that location.
    def _resolve(path, force=false)
      if path.nil?
        nil
      elsif path.is_a?(Regexp)
        path
      # If the path is relative...
      elsif path[0..0] != '/' && (File.file?(p = File.expand_path("#{_[:dir]}/#{path}")) || force)
        p
      # If the path is root...
      elsif File.file?(p = File.expand_path("#{_[:root]}/#{path}")) || force
        p
      # If the path is absolute...
      elsif File.file?(path)
        path
      else
        false
      end
    end

    class <<self

      # Returns an `Array` of `Plugin` classes within the `Stasis` namespace.
      def find_plugins
        Stasis.constants.inject([]) do |array, klass|
          klass = eval(klass.to_s)
          if klass < Plugin
            array << klass
          end
          array
        end
      end
    end
  end
end