require 'spec_helper'

describe Stasis::Before do

  before(:all) do
    generate
  end
  
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

  it "should render text to before_render_text.html" do
    $files['before_render_text.html'].should =~ /root/
  end

  it "should render text to subdirectory/before_render_text.html" do
    $files['subdirectory/before_render_text.html'].should =~ /subdirectory/
  end

  it "should render partial to before_render_text.html" do
    $files['before_render_partial.html'].should =~ /root/
  end

  it "should render partial to subdirectory/before_render_text.html" do
    $files['subdirectory/before_render_partial.html'].should =~ /subdirectory/
  end

  it "should render partial to before_non_existent.html" do
    $files['before_non_existent.html'].should =~ /root/
  end

  it "should render partial to subdirectory/before_non_existent.html" do
    $files['subdirectory/before_non_existent.html'].should =~ /subdirectory/
  end
end
