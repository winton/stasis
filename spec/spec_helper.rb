require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/stasis/gems"

Stasis::Gems.activate :rspec

require "#{$root}/lib/stasis"

Spec::Runner.configure do |config|
end