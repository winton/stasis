# `Controller` provides a scope for `controller.rb` files.
#
# Stasis will still create a `Controller` instance for directories without a
# `controller.rb` file, mostly for the purposes of resolving paths and triggering plugin
# events.

class Stasis
  class Controller < Scope
    
    # `Hash` -- Contains four key/value pairs:
    #
    # * `dir` -- Directory for which this controller provides a scope.
    # * `path` -- Path to the `controller.rb` file (if it exists).
    # * `plugins` -- A new instance of all known plugins.
    # * `root` -- The root directory path of the user's project.
    #
    # The class variable is named `@_` so that there is little likelihood that a
    # user-defined variable will conflict.
    attr_reader :_
    
    def initialize(dir, root)
      dir = File.expand_path(dir)
      path = "#{dir}/controller.rb"
      path = nil unless File.file?(path)
      @_ = {
        :dir => dir,
        :path => path,
        :plugins => self.class.find_plugins.collect { |klass| klass.new },
        :root => root
      }
      _bind_plugins(:controller_method)
      instance_eval(File.read(path), path) if path
    end

    def resolve(path, force=false)
      if path.nil?
        nil
      elsif path.is_a?(Regexp)
        path
      elsif path[0..0] != '/' && (File.file?(p = File.expand_path("#{_[:dir]}/#{path}")) || force)
        p
      elsif File.file?(p = File.expand_path("#{_[:root]}/#{path}")) || force
        p
      elsif File.file?(path)
        path
      else
        false
      end
    end

    class <<self

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