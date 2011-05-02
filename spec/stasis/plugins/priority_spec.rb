require 'spec_helper'

describe Stasis::Priority do

  before(:all) do
    @fixture = "#{$root}/spec/fixtures/project"
  end
  
  it "should prioritize to top" do
    top_2 = $render_order[0..1]
    top_2.any? { |p| p == "#{@fixture}/subdirectory/rename_to_root.html.haml" }.should == true
    top_2.any? { |p| p == "#{@fixture}/rename_to_subdirectory.html.haml" }.should == true
  end

  it "should prioritize to bottom" do
    bot_2 = $render_order[-2..-1]
    bot_2.any? { |p| p == "#{@fixture}/subdirectory/index.html.haml" }.should == true
    bot_2.any? { |p| p == "#{@fixture}/index.html.haml" }.should == true
  end
end
