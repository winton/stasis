require 'rubygems'
require 'bundler'

Bundler.require(:spec)

require 'lib/gem_template'
require 'pp'

Spec::Runner.configure do |config|
end

SPEC = File.expand_path("#{Bundler.root}/spec")
$:.unshift File.expand_path("#{Bundler.root}/lib")

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end
