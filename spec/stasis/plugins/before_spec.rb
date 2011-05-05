require 'spec_helper'

describe Stasis::Before do
  
  it "should set class variables for index.html" do
    $files['index.html'].should =~ /@before_index_literal\nroot/
    $files['index.html'].should =~ /@before_index_regexp\nroot/
    $files['index.html'].should =~ /@before_all\nroot/
    $files['index.html'].should =~ /@fail\nfalse/
  end

  it "should set class variables for subdirectory/index.html" do
    $files['subdirectory/index.html'].should =~ /@before_index_literal\nsubdirectory/
    $files['subdirectory/index.html'].should =~ /@before_index_regexp\nsubdirectory/
    $files['subdirectory/index.html'].should =~ /@before_all\nsubdirectory/
    $files['subdirectory/index.html'].should =~ /@fail\nfalse/
  end

  it "should set class variables for no_controller/index.html" do
    $files['no_controller/index.html'].should =~ /@before_index_literal\nno_controller/
    $files['no_controller/index.html'].should =~ /@before_index_regexp\nroot/
    $files['no_controller/index.html'].should =~ /@before_all\nroot/
    $files['no_controller/index.html'].should =~ /@fail\nfalse/
  end
end
