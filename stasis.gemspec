# -*- encoding: utf-8 -*-
root = File.expand_path('../', __FILE__)
lib = "#{root}/lib"

$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "stasis"
  s.version     = '0.1.20'
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Winton Welsh' ]
  s.email       = [ 'mail@wintoni.us' ]
  s.homepage    = "http://stasis.me"
  s.summary     = %q{Static sites made powerful}
  s.description = %q{Stasis is a dynamic framework for static sites.}

  s.executables = `cd #{root} && git ls-files bin/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")

  s.add_development_dependency "albino"
  s.add_development_dependency "coffee-script"
  s.add_development_dependency "haml"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "rake"
  s.add_development_dependency "rocco"
  s.add_development_dependency "rspec", "~> 1.0"

  s.add_dependency "directory_watcher", "~> 1.4.1"
  s.add_dependency "redis",             "~> 2.2.2"
  s.add_dependency "slop",              "~> 2.4.4"
  s.add_dependency "tilt",              "~> 1.3.3"
  s.add_dependency "yajl-ruby",         "~> 1.0.0"
end