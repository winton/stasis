require 'rubygems'
require 'bundler'

Bundler.require(:rakefile)

require 'rake'

begin
  require 'spec/rake/spectask'
rescue Exception => e
end

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../gem_template.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

if defined?(Spec::Rake::SpecTask)
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.warning = true
  end
  task :spec
  task :default => :spec
end

desc "Build gem(s)"
task :gem do
  root = File.expand_path('../', __FILE__)
  pkg = "#{root}/pkg"
  system "rm -Rf #{pkg}"
  system "cd #{root} && gem build gem_template.gemspec"
  system "mkdir -p #{pkg} && mv *.gem pkg"
end

namespace :gem do
  desc "Install gem(s)"
  task :install do
    Rake::Task['gem'].invoke
    Dir["#{File.dirname(__FILE__)}/pkg/*.gem"].each do |pkg|
      system "gem install #{pkg} --no-ri --no-rdoc"
    end
  end
  
  desc "Push gem(s)"
  task :push do
    Rake::Task['gem'].invoke
    Dir["#{File.dirname(__FILE__)}/pkg/*.gem"].each do |pkg|
      system "gem push #{pkg}"
    end
  end
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

# DELETE AFTER USING
desc "Rename project"
task :rename do
  name = ENV['NAME'] || File.basename(Dir.pwd)
  camelize = lambda do |str|
    str.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
  dir = Dir['**/gem_template*']
  begin
    from = dir.pop
    if from
      to = from.split('/')
      to[-1].gsub!('gem_template', name)
      FileUtils.mv(from, to.join('/'))
    end
  end while dir.length > 0
  Dir["**/*"].each do |path|
    if File.file?(path)
      `sed -i '' 's/gem_template/#{name}/g' #{path}`
      `sed -i '' 's/GemTemplate/#{camelize.call(name)}/g' #{path}`
      no_space = File.read(path).gsub(/\s+\z/, '')
      File.open(path, 'w') { |f| f.write(no_space) }
    end
  end
end