require File.dirname(__FILE__) + '/lib/gem_template/gems'

GemTemplate::Gems.require(:rake)

require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../gem_template.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

if defined?(Rake::GemPackageTask)
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => :gemspec
end

if defined?(Spec::Rake::SpecTask)
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.warning = true
  end
  task :spec
end

namespace :gems do
  desc "Install gems (DEV=1|0 DOCS=1|0 SUDO=1|0)"
  task :install do
    file = File.dirname(__FILE__) + '/gems'
    sudo = (ENV['SUDO'] ||= '0').to_i
    docs = (ENV['DOCS'] ||= '0').to_i
    sudo = sudo == 1 ? 'sudo' : ''
    docs = docs == 1 ? '' : '--no-ri --no-rdoc'
    gems = []
    
    if File.exists?(file)
      File.open(file, 'r') do |f|
        gems = f.readlines.collect do |line|
          line.split(' ')
        end
      end
    else
      gems = GemTemplate::Gems::TYPES[:gemspec]
      gems = GemTemplate::Gems::TYPES[:gemspec_dev] if ENV['DEV'] == '1'
      gems.collect! do |g|
        [ g.to_s, GemTemplate::Gems::VERSIONS[g] ]
      end
    end
    
    gems.each do |(name, version)|      
      if Gem.source_index.find_name(name, version).empty?
        version = version ? "-v #{version}" : ''
        system "#{sudo} gem install #{name} #{version} #{docs}"
      else
        puts "already installed: #{name} #{version}"
      end
    end
  end
end

desc "Install gem locally"
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

task :package => :gemspec
task :default => :spec

# DELETE AFTER USING
desc "Rename project"
task :rename do
  name = ENV['NAME'] || File.basename(Dir.pwd)
  camelize = lambda do |str|
    str.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
  begin
    dir = Dir['**/gem_template*']
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