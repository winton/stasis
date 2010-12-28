unless defined?(GemTemplate::Gemspec)
  
  require 'yaml'
  
  module GemTemplate
    class Gemspec
      class <<self
      
        attr_accessor :data
        
        def reload
          Gemspec.data =
            YAML::load(
              File.read(
                "#{File.expand_path('../../../', __FILE__)}/config/gemspec.yml"
              )
            ) rescue {}

          Gemspec.data.each do |key, value|
            self.send :eval, <<-EVAL
              def #{key}
                #{value.inspect}
              end
            EVAL
          end
        end
        
        Gemspec.reload
      end
    end
  end
end