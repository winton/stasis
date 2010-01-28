require "#{File.dirname(__FILE__)}/require"
Require.rakefile!

# You can delete this after you use it
desc "Rename project"
task :rename do
  name = ENV['NAME'] || File.basename(Dir.pwd)
  begin
    dir = Dir['**/gem_template*']
    from = dir.pop
    if from
      rb = from.include?('.rb')
      to = File.dirname(from) + "/#{name}#{'.rb' if rb}"
      FileUtils.mv(from, to)
    end
  end while dir.length > 0
  Dir["**/*"].each do |path|
    next if path.include?('Rakefile')
    if File.file?(path)
      `sed -i "" 's/gem_template/#{name}/g' #{path}`
    end
  end
end