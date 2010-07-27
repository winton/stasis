unless defined?(GemTemplate::Gems)
  
  require 'rubygems'
  
  module GemTemplate
    class Gems
    
      VERSIONS = {
        :rake => '=0.8.7',
        :rspec => '=1.3.0'
      }
    
      TYPES = {
        :gemspec => [],
        :gemspec_dev => [ :rspec ],
        :lib => [],
        :rake => [ :rake, :rspec ],
        :spec => [ :rspec ]
      }
      
      class <<self
        
        def lockfile
          file = File.expand_path('../../../gems', __FILE__)
          unless File.exists?(file)
            File.open(file, 'w') do |f|
              Gem.loaded_specs.each do |key, value|
                f.puts "#{key} #{value.version.version}"
              end
            end
          end
        end
        
        def require(type=nil)
          (TYPES[type] || TYPES.values.flatten.compact).each do |name|
            gem name.to_s, VERSIONS[name]
          end
        end
      end
    end
  end
end