require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Bundler.setup(:development)

require 'rocco/tasks'

desc "Build web site"
task :site do
  cmd = [
    'cd site',
    '../bin/stasis',
    'rm -rf ../../public',
    'mv public ../../',
    'cd ../',
    'git checkout gh-pages',
    'rm -rf *.png *.html *.css *.js site',
    'mv ../public/* .'
  ].join '&&'
  `#{cmd}`
end

desc "Build Rocco Docs"
Rocco::make 'docs/'

RSpec::Rake::SpecTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end
task :default  => :spec
