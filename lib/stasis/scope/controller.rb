# `Controller` provides a scope for `controller.rb` files.
#
# Stasis will still create a `Controller` instance for directories without a
# `controller.rb` file, mostly for the purposes of resolving paths and triggering plugin
# events.

class Stasis
  class Controller < Scope
    
    def initialize(stasis)
      @_stasis = stasis

      # Some plugins define methods to be made available to controller scopes. This call
      # binds those methods.
      @_stasis.plugins.each do |plugin|
        _bind_plugin(plugin, :controller_method)
      end
    end

    def _add(path)
      return unless File.file?(path) && File.basename(path) == 'controller.rb'

      # Temporarily set path variables.
      @_stasis.path = path
      
      # Evaluate `controller.rb`.
      instance_eval(File.read(path), path)

      # Unset temporary path variables.
      @_stasis.path = nil
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
      elsif path[0..0] != '/' && @_stasis.path && (File.file?(p = File.expand_path("#{File.dirname(@_stasis.path)}/#{path}")) || force)
        p
      # If the path is root...
      elsif File.file?(p = File.expand_path("#{@_stasis.root}/#{path}")) || force
        p
      # If the path is absolute...
      elsif File.file?(path)
        path
      else
        false
      end
    end
  end
end