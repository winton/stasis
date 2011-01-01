require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/gem_template/gems"

GemTemplate::Gems.activate :rspec

require "#{$root}/lib/gem_template"

Spec::Runner.configure do |config|
end