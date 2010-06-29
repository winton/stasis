require 'rubygems'
require 'bundler'

Bundler.require(:lib)

$:.unshift File.dirname(__FILE__) + '/gem_template'

require 'version'

module GemTemplate
end