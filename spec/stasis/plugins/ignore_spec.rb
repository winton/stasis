require 'spec_helper'

describe Stasis::Ignore do
  
  it "should ignore partials" do
    $files['_partial.html'].should == nil
    $files['subdirectory/_partial.html'].should == nil
  end

  it "should ignore subdirectory/ignore.html.haml" do
    $files['subdirectory/ignore.html'].should == nil
  end
end
