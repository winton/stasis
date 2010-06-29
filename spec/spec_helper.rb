require 'rubygems'
require 'bundler'

Bundler.require(:spec)

Spec::Runner.configure do |config|
end

SPEC = File.dirname(__FILE__)

require "#{Bundler.root}/lib/gem_template"
require 'pp'

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end
