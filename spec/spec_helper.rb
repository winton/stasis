require "pp"
require "bundler"

Bundler.setup(:default)
Bundler.require(:development)

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/stasis"

def generate(options={})
  $files = nil if options[:reload]
  $fixture = "#{$root}/spec/fixtures/project"
  unless $files
    $stasis ||= Stasis.new($fixture)
    $stasis.render(*options[:only])
    generate_files
  end
end

def generate_files
  pub = "#{$fixture}/public"
  $files = Dir["#{pub}/**/*"].inject({}) do |hash, path|
    if File.file?(path)
      hash[path[pub.length+1..-1]] = File.read(path)
    end
    hash
  end
end