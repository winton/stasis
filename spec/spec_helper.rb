$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/gem_template/gems"

GemTemplate::Gems.activate :rspec

require "#{$root}/lib/gem_template"
require 'pp'

Spec::Runner.configure do |config|
end

def capture_stdout
  old = $stdout
  out = StringIO.new
  $stdout = out
  yield
  return out.string
ensure
  $stdout = old
end