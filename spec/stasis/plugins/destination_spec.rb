require 'spec_helper'

describe Stasis::Destination do
  
  it "should change the destination for files in root" do
    $files['renamed_action.html'].should =~ /pass/
    $files['renamed_controller.html'].should =~ /pass/
    $files['renamed_to_root.html'].should =~ /pass/
  end

  it "should change the destination for files in the subdirectory" do
    $files['subdirectory/renamed_action.html'].should =~ /pass/
    $files['subdirectory/renamed_controller.html'].should =~ /pass/
    $files['subdirectory/renamed_to_subdirectory.html'].should =~ /pass/
  end
end
