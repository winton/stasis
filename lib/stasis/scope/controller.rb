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

      # Change current working directory.
      Dir.chdir(File.dirname(path))
      
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
    def _resolve(path, force=false)
      return nil  if path.nil?
      return path if path.is_a?(Regexp)
      Stasis::Resolve.new(@_stasis, path).real_path
    end
  end
end
