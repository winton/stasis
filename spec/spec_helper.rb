$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/gem_template/gems"

GemTemplate::Gems.require(:spec)

Spec::Runner.configure do |config|
end

require "#{Bundler.root}/lib/gem_template"
require 'pp'

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end
