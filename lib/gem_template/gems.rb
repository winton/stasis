unless defined?(GemTemplate::Gems)
  
  require 'yaml'
  
  module GemTemplate
    module Gems
      class <<self
        
        attr_accessor :config
        attr_reader :gemset, :gemsets, :versions
        
        class SimpleStruct
          attr_reader :hash
          
          def initialize(hash)
            @hash = hash
            @hash.each do |key, value|
              self.class.send(:define_method, key) { @hash[key] }
              self.class.send(:define_method, "#{key}=") { |v| @hash[key] = v }
            end
          end
        end
        
        Gems.config = SimpleStruct.new(
          :gemsets => [ "#{File.expand_path('../../../', __FILE__)}/config/gemsets.yml" ],
          :gemspec => "#{File.expand_path('../../../', __FILE__)}/config/gemspec.yml",
          :warn => true
        )
        
        def activate(*gems)
          begin
            require 'rubygems' unless defined?(::Gem)
          rescue LoadError
            puts "rubygems library could not be required" if @config.warn
          end
          
          self.gemset ||= gemset_from_loaded_specs
          
          gems.flatten.collect(&:to_sym).each do |name|
            version = @versions[name]
            vendor = File.expand_path("../../../vendor/#{name}/lib", __FILE__)
            if File.exists?(vendor)
              $:.unshift vendor
            elsif defined?(gem)
              gem name.to_s, version
            else
              puts "#{name} #{"(#{version})" if version} failed to activate" if @config.warn
            end
          end
        end
        
        def dependencies
          dependency_filter(@gemspec.dependencies, @gemset)
        end
        
        def development_dependencies
          dependency_filter(@gemspec.development_dependencies, @gemset)
        end
        
        def gemset=(gemset)
          if gemset
            @gemset = gemset.to_sym
        
            @gemsets = @config.gemsets.reverse.collect { |config|
              if config.is_a?(::String)
                YAML::load(File.read(config)) rescue {}
              elsif config.is_a?(::Hash)
                config
              end
            }.inject({}) do |hash, config|
              deep_merge(hash, symbolize_keys(config))
            end
            
            @versions = (@gemsets[gemspec.name.to_sym] || {}).inject({}) do |hash, (key, value)|
              if !value.is_a?(::Hash) && value
                hash[key] = value
              elsif key == @gemset
                (value || {}).each { |k, v| hash[k] = v }
              end
              hash
            end
          else
            @gemset = nil
            @gemsets = nil
            @versions = nil
          end
        end
        
        def gemset_names
          (
            [ :default ] +
            @gemsets[gemspec.name.to_sym].inject([]) { |array, (key, value)|
              array.push(key) if value.is_a?(::Hash) || value.nil?
              array
            }
          ).uniq
        end
        
        def gemspec(reload=false)
          if @gemspec && !reload
            @gemspec
          else
            data = YAML::load(File.read(@config.gemspec)) rescue {}
            @gemspec = SimpleStruct.new(data)
          end
        end
      
        private
      
        def deep_merge(first, second)
          merger = lambda do |key, v1, v2|
            Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
          end
          first.merge(second, &merger)
        end
        
        def dependency_filter(dependencies, match)
          (dependencies || []).inject([]) { |array, value|
            if value.is_a?(::Hash)
              array += value[match.to_s] if value[match.to_s]
            else
              array << value
            end
            array
          }.uniq.collect(&:to_sym)
        end
        
        def gemset_from_loaded_specs
          if defined?(Gem)
            Gem.loaded_specs.each do |name, spec|
              if name == gemspec.name
                return :default
              elsif name[0..gemspec.name.length] == "#{gemspec.name}-"
                return name[gemspec.name.length+1..-1].to_sym
              end
            end
            :default
          else
            :none
          end
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