class Stasis
  class Context
    class Controller
      
      attr_reader :_
      include Plugin::Helpers
      
      def initialize(dir, root)
        dir = File.expand_path(dir)
        path = "#{dir}/controller.rb"
        path = nil unless File.file?(path)
        @_ = {
          :dir => dir,
          :path => path,
          :plugins => _find_plugins,
          :root => root
        }
        _bind_plugins(:controller_method)
        instance_eval(File.read(path), path) if path
      end

      def resolve(path)
        if path.nil?
          nil
        elsif path.is_a?(Regexp)
          path
        elsif path[0..0] != '/' && File.file?(p = File.expand_path("#{_[:dir]}/#{path}"))
          p
        elsif File.file?(p = File.expand_path("#{_[:root]}/#{path}"))
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