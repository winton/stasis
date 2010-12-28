# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  GemTemplate::Gemspec.data.each do |key, value|
    unless %w(dependencies development_dependencies).include?(key)
      s.send "#{key}=", value
    end
  end

  GemTemplate::Gemspec.dependencies.each do |g|
    s.add_dependency g.to_s, GemTemplate::Gems.versions[g]
  end
  
  GemTemplate::Gemspec.development_dependencies.each do |g|
    s.add_development_dependency g.to_s, GemTemplate::Gems.versions[g]
  end

  s.executables = `git ls-files -- {bin}/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `git ls-files -- {features,test,spec}/*`.split("\n")
end