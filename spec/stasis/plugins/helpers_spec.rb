require 'spec_helper'

describe Stasis::Helpers do
  
  it "should display the helper in index.html" do
    $files['index.html'].should =~ /helpers\nroot/
  end

  it "should display the helper in subdirectory/index.html" do
    $files['subdirectory/index.html'].should =~ /helpers\nsubdirectory/
  end
end
