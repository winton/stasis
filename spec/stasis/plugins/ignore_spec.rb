require 'spec_helper'

describe Stasis::Ignore do

  before(:all) do
    generate
  end
  
  it "should ignore partials" do
    $files['_partial.html'].should == nil
    $files['subdirectory/_partial.html'].should == nil
  end

  it "should ignore subdirectory/ignore.html.haml" do
    $files['subdirectory/ignore.html'].should == nil
  end

  it "should ignore ignored_subdirectory/controller.rb" do
    plugin = $stasis.plugins.find { |plugin| plugin.is_a?(Stasis::Ignore) }
    plugin.ignore_controller?($stasis.controller._resolve('ignored_subdirectory/controller.rb')).should be_true
  end
end
