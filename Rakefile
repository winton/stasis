require 'bundler'
require 'bundler/gem_tasks'
require 'spec/rake/spectask'

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

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
task :default  => :spec