require 'spec_helper'

describe Stasis::Layout do

  before(:all) do
    generate
  end
  
  it "should render root layouts" do
    $files['layout_action.html'].should =~ /layout\nroot\npass/
    $files['layout_action_false.html'].should == "pass\n"
    $files['layout_action_from_subdirectory.html'].should =~ /layout\nsubdirectory\npass/
    $files['layout_controller.html'].should =~ /layout\nroot\npass/
    $files['layout_controller_from_subdirectory.html'].should =~ /layout\nsubdirectory\npass/
  end

  it "should render subdirectory layouts" do
    $files['subdirectory/layout_action.html'].should =~ /layout\nsubdirectory\npass/
    $files['subdirectory/layout_action_false.html'].should == "pass\n"
    $files['subdirectory/layout_action_from_root.html'].should =~ /layout\nroot\npass/
    $files['subdirectory/layout_controller.html'].should =~ /layout\nsubdirectory\npass/
    $files['subdirectory/layout_controller_from_root.html'].should =~ /layout\nroot\npass/
  end

  it "should use layouts on matching extensions" do
    $files['erb.html'].should =~ /erb layout/
    $files['erb.html'].should =~ /erb template/
    $files['css.css'].should_not =~ /erb layout/
  end
end
