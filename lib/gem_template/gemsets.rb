unless defined?(GemTemplate::Gemsets)
  
  require "#{File.dirname(__FILE__)}/gems"
  require "#{File.dirname(__FILE__)}/gemspec"
  
  require 'yaml'
  
  module GemTemplate
    class Gemsets
      class <<self
        
        attr_accessor :configs, :gemset, :gemsets
        
        Gemsets.configs = [ "#{File.expand_path('../../../', __FILE__)}/config/gemsets.yml" ]
        
        def gemset=(gemset)
          if gemset
            @gemset = gemset.to_sym
          
            @gemsets = @configs.reverse.collect { |config|
              if config.is_a?(::String)
                YAML::load(File.read(config)) rescue {}
              elsif config.is_a?(::Hash)
                config
              end
            }.inject({}) do |hash, config|
              deep_merge(hash, symbolize_keys(config))
            end
          
            Gems.versions = @gemsets[Gemspec.name.to_sym].inject({}) do |hash, (key, value)|
              if value.is_a?(::String)
                hash[key] = value
              elsif value.is_a?(::Hash) && key == @gemset
                value.each { |k, v| hash[k] = v }
              end
              hash
            end
          else
            @gemset = nil
            @gemsets = nil
            Gems.versions = nil
          end
        end
        
        private
        
        def deep_merge(first, second)
          merger = lambda do |key, v1, v2|
            Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
          end
          first.merge(second, &merger)
        end
        
        def symbolize_keys(hash)
          return {} unless hash.is_a?(::Hash)
          hash.inject({}) do |options, (key, value)|
            value = symbolize_keys(value) if value.is_a?(::Hash)
            options[(key.to_sym rescue key) || key] = value
            options
          end
        end
      end
    end
  end
end