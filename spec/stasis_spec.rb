require 'spec_helper'

describe Stasis do

  before(:all) do
    generate
  end

  it "should preserve dotfiles" do
    $files.keys.include?(".dotfile").should == true
  end
  
  it "should copy files that are not markup" do
    $files['not_dynamic.html'].should =~ /pass/
  end

  it "should use the custom plugin" do
    $files['custom_plugin.html'].should =~ /pass/
  end

  context "default extensions for Sass and CoffeeScript files without infix extension" do
    it "should use .css for no_middle_extension.scss" do
      $files['no_middle_extension.css'].should_not be_nil
    end

    it "should use .js for no_middle_extension.coffee" do
      $files['no_middle_extension.js'].should_not be_nil
    end
  end

  describe 'generate with :only option' do
    
    before(:each) do
      @index_time = $files['index.html'].split("time")[1].strip
      @time_time = $files['time.html'].split("time")[1].strip
    end
    
    describe :string do

      it "should respect the :only option" do
        generate(:only => 'time.html.haml', :reload => true)
        new_index_time = $files['index.html'].split("time")[1].strip
        new_time_time = $files['time.html'].split("time")[1].strip
        new_index_time.should == @index_time
        new_time_time.should_not == @time_time
      end
    end

    describe :regex do

      it "should respect the :only option" do
        generate(:only => /time.html.haml/, :reload => true)
        new_index_time = $files['index.html'].split("time")[1].strip
        new_time_time = $files['time.html'].split("time")[1].strip
        new_index_time.should == @index_time
        new_time_time.should_not == @time_time
      end
    end
  end
end
