unless defined?(GemTemplate::Gems)
  
  require "#{File.dirname(__FILE__)}/gemsets"
  
  module GemTemplate
    class Gems
      class <<self
        
        attr_accessor :testing, :versions, :warn
        
        Gems.testing = false
        Gems.warn = true
        
        def activate(*gems)
          begin
            require 'rubygems' if !defined?(::Gem) || @testing
          rescue LoadError
            puts "rubygems library could not be required" if @warn
          end
          
          Gemsets.gemset = :default unless defined?(@gemset)
          
          gems.flatten.collect(&:to_sym).each do |name|
            version = @versions[name]
            if defined?(gem)
              gem name.to_s, version
            else
              puts "#{name} #{"(#{version})" if version} failed to activate" if @warn
            end
          end
        end
      end
    end
  end
end