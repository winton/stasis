require 'spec_helper'

describe Stasis::Priority do

  before(:all) do
    generate
  end
  
  it "should prioritize to top" do
    # One of these will render a partial, so grabbing the top 3 instead of 2.
    top_3 = $render_order[0..2]
    top_3.any? { |p| p == "#{$fixture}/subdirectory/before_render_partial.html.haml" }.should == true
    top_3.any? { |p| p == "#{$fixture}/before_render_partial.html.haml" }.should == true
  end

  it "should prioritize to bottom" do
    # These both render two partials each, so grab the bottom 6 instead of 2.
    bot_6 = $render_order[-6..-1]
    bot_6.any? { |p| p == "#{$fixture}/subdirectory/index.html.haml" }.should == true
    bot_6.any? { |p| p == "#{$fixture}/index.html.haml" }.should == true
  end
end
