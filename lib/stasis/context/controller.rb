class Stasis
  class Context
    class Controller
      
      attr_reader :_
      include Plugin::Helpers
      
      def initialize(path, plugins, root)
        @_ = {
          :dir => File.dirname(path),
          :path => path,
          :plugins => plugins,
          :rel_dir => File.dirname(path)[root.length+1..-1],
          :root => root
        }
        _bind_plugins(:controller_method)
        instance_eval File.read(path), path
      end

      def resolve(path)
        if path.nil?
          nil
        elsif path.is_a?(Regexp)
          path
        elsif File.file?(p = "#{_[:dir]}/#{path}")
          p
        elsif File.file?(p = "#{_[:root]}/#{path}")
          p
        elsif File.file?(path)
          path
        else
          false
        end
      end
    end
  end
end