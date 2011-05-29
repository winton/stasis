require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/stasis/gems"

Stasis::Gems.activate :rspec

require "#{$root}/lib/stasis"

def generate(options={})
  $files = nil if options[:reload]
  $fixture = "#{$root}/spec/fixtures/project"
  unless $files
    $stasis ||= Stasis.new($fixture)
    $stasis.generate(options)
    pub = "#{$fixture}/public"
    $files = Dir["#{pub}/**/*"].inject({}) do |hash, path|
      if File.file?(path)
        hash[path[pub.length+1..-1]] = File.read(path)
      end
      hash
    end
  end
end