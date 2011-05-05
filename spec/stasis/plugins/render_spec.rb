require 'spec_helper'

describe Stasis::Render do

  before(:all) do
    @fixture = "#{$root}/spec/fixtures/project"
  end
  
  it "should render partials into index.html" do
    $files['index.html'].should =~ /render from root\nroot/
    $files['index.html'].should =~ /render from subdirectory\nsubdirectory/
  end

  it "should render partials into subdirectory/index.html" do
    $files['subdirectory/index.html'].should =~ /render from root\nroot/
    $files['subdirectory/index.html'].should =~ /render from subdirectory\nsubdirectory/
  end

  it "should render partials into no_controller/index.html" do
    $files['no_controller/index.html'].should =~ /render from root\nroot/
    $files['no_controller/index.html'].should =~ /render from subdirectory\nsubdirectory/
  end
end
