require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/stasis/gems"

Stasis::Gems.activate :rspec

require "#{$root}/lib/stasis"

Spec::Runner.configure do |config|
end

def setup_fixtures
  unless @files
    stasis = Stasis.new("#{$root}/spec/fixtures/project")
    stasis.generate
    pub = "#{$root}/spec/fixtures/project/public"
    @files = Dir["#{pub}/**/*"].inject({}) do |hash, path|
      if File.file?(path)
        hash[path[pub.length+1..-1]] = File.read(path)
      end
      hash
    end
  end
end