source "http://rubygems.org"

v = {
  :bundler => '=1.0.0.beta.2',
  :rake => '=0.8.7',
  :rspec => '=1.3.0'
}

group :gemspec do
  gem 'bundler', v[:bundler]
end

group :gemspec_dev do
  gem 'rspec', v[:rspec]
end

group :lib do
end

group :rake do
  gem 'rake', v[:rake], :require => %w(rake rake/gempackagetask)
  gem 'rspec', v[:rspec], :require => %w(spec/rake/spectask)
end

group :spec do
end