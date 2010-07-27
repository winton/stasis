require File.dirname(__FILE__) + '/gem_template/gems'

GemTemplate::Gems.require(:lib)

$:.unshift File.dirname(__FILE__) + '/gem_template'

require 'version'

module GemTemplate
end