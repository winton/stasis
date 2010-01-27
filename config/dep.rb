require 'rubygems'
require 'dep'

Dep do
  gem :dep, '=0.1.2'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :rspec, '=1.3.0'
  
  gemspec do
    author 'Winton Welsh'
    dependencies do
      gem :dep
    end
    email 'mail@wintoni.us'
    name 'gem_template'
    homepage "http://github.com/winton/#{name}"
    root File.expand_path("#{File.dirname(__FILE__)}/../")
    summary ""
    version '0.1.0'
  end
  
  bin { require 'lib/gem_template' }
  lib { require 'lib/gem_template/gem_template' }
  
  rakefile do
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'dep/tasks'
  end
  
  spec_helper do
    require 'dep/spec_helper'
    require 'lib/gem_template'
    require 'pp'
  end
end