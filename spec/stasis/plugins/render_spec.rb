require 'spec_helper'

describe Stasis::Render do

  before(:all) do
    generate
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

  it "should render locals into before_render_locals.html" do
    $files['before_render_locals.html'].should =~ /true/
  end

  it "should render locals into subdirectory/before_render_locals.html" do
    $files['subdirectory/before_render_locals.html'].should =~ /true/
  end

  it "should render locals into render_locals.html" do
    $files['render_locals.html'].should =~ /true/
  end

  it "should render locals into subdirectory/render_locals.html" do
    $files['subdirectory/render_locals.html'].should =~ /true/
  end
end
