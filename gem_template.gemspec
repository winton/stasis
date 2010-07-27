# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'gem_template/gems'
require 'gem_template/version'

Gem::Specification.new do |s|
  s.name = "gem_template"
  s.version = GemTemplate::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Winton Welsh"]
  s.email = ["mail@wintoni.us"]
  s.homepage = "http://github.com/winton/gem_template"
  s.summary = ""
  s.description = ""

  GemTemplate::Gems::TYPES[:gemspec].each do |g|
    s.add_dependency g.to_s, GemTemplate::Gems::VERSIONS[g]
  end
  
  GemTemplate::Gems::TYPES[:gemspec_dev].each do |g|
    s.add_development_dependency g.to_s, GemTemplate::Gems::VERSIONS[g]
  end

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables = Dir.glob("{bin}/*").collect { |f| File.basename(f) }
  s.require_path = 'lib'
end