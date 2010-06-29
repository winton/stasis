# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'gem_template/version'
require 'rubygems'
require 'bundler'

Gem::Specification.new do |s|
  s.name = "gem_template"
  s.version = GemTemplate::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Winton Welsh"]
  s.email = ["mail@wintoni.us"]
  s.homepage = "http://github.com/winton/gem_template"
  s.summary = ""
  s.description = ""

  Bundler.definition.dependencies.each do |dep|
    if dep.groups.include?(:gemspec)
      s.add_dependency dep.name, dep.requirement
    elsif dep.groups.include?(:gemspec_dev)
      s.add_development_dependency dep.name, dep.requirement
    end
  end

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables = Dir.glob("{bin}/*").collect { |f| File.basename(f) }
  s.require_path = 'lib'
end