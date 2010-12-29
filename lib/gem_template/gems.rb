unless defined?(GemTemplate::Gems)
  
  require 'ostruct'
  require 'yaml'
  
  module GemTemplate
    module Gems
      class <<self
        
        attr_accessor :configs, :gemset, :gemsets, :gemspec, :testing, :versions, :warn
        
        Gems.configs = [ "#{File.expand_path('../../../', __FILE__)}/config/gemsets.yml" ]
        Gems.testing = false
        Gems.warn = true
        
        class Gemspec
          attr_accessor :hash
          
          def initialize(hash)
            @hash = hash
            @hash.each do |key, value|
              self.class.send(:define_method, key) { value }
            end
          end
        end
        
        def activate(*gems)
          begin
            require 'rubygems' if !defined?(::Gem) || @testing
          rescue LoadError
            puts "rubygems library could not be required" if @warn
          end
          
          self.gemset = :default unless defined?(@gemset) && @gemset
          
          gems.flatten.collect(&:to_sym).each do |name|
            version = @versions[name]
            if defined?(gem)
              gem name.to_s, version
            else
              puts "#{name} #{"(#{version})" if version} failed to activate" if @warn
            end
          end
        end
        
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
        
            @versions = @gemsets[@gemspec.name.to_sym].inject({}) do |hash, (key, value)|
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
            @versions = nil
          end
        end
        
        def reload_gemspec
          data =
            YAML::load(
              File.read(
                "#{File.expand_path('../../../', __FILE__)}/config/gemspec.yml"
              )
            ) rescue {}
          
          @gemspec = Gemspec.new(data)
        end
        
        Gems.reload_gemspec
      
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