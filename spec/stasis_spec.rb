require 'spec_helper'

describe Stasis do
  
  it "should copy files that are not markup" do
    $files['not_dynamic.html'].should =~ /pass/
  end
end