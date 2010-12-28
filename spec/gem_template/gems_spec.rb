require 'spec_helper'

describe GemTemplate::Gems do
  
  before(:each) do
    GemTemplate::Gemsets.configs = [
      "#{$root}/spec/fixtures/gemsets.yml"
    ]
    GemTemplate::Gemsets.gemset = nil
    GemTemplate::Gems.testing = true
  end
  
  describe :activate do
    it "should warn if unable to require rubygems" do
      GemTemplate::Gems.stub!(:require)
      GemTemplate::Gems.should_receive(:require).with('rubygems').and_raise(LoadError)
      GemTemplate::Gems.stub!(:gem)
      out = capture_stdout do
        GemTemplate::Gems.activate :rspec
      end
      out.should =~ /rubygems library could not be required/
    end
    
    it "should activate gems" do
      GemTemplate::Gems.stub!(:gem)
      GemTemplate::Gems.should_receive(:gem).with('rspec', '=1.3.1')
      GemTemplate::Gems.should_receive(:gem).with('rake', '=0.8.7')
      GemTemplate::Gems.activate :rspec, 'rake'
    end
  end
end
