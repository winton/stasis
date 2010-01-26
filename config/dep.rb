require 'rubygems'
require 'dep'

Dep.gem do
  
  dep '=0.1.1'
  rake '=0.8.7', :require => %w(rake)
  rspec '=1.3.0'
end

Dep.gemspec do

  author 'Winton Welsh'
  email 'mail@wintoni.us'
  name 'gem_template'
  homepage "http://github.com/winton/#{name}"
  root File.expand_path("#{File.dirname(__FILE__)}/../")
  summary ""
  version '0.1.0'
end

Dep.profile do
  
  bin :require => %w(lib/gem_template)
  
  gemspec do
    dep
  end
  
  lib :require => %w(lib/gem_template/gem_template)
  
  rakefile :require => %w(dep/tasks) do
    rake :require => %w(rake/gempackagetask)
    rspec :require => %w(spec/rake/spectask)
  end
  
  spec_helper :require => %w(dep/spec_helper lib/gem_template pp)
end