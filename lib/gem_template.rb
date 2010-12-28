require File.dirname(__FILE__) + '/gem_template/gems'

GemTemplate::Gems.activate %w()

$:.unshift File.dirname(__FILE__)

module GemTemplate
end