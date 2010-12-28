require 'spec_helper'

describe GemTemplate::Gemsets do
  
  before(:each) do
    GemTemplate::Gemsets.configs = [
      {
        :gem_template => {
          :rake => '>0.8.6',
          :default => {
            :externals => '=1.0.2'
          }
        }
      },
      "#{$root}/spec/fixtures/gemsets.yml"
    ]
  end
  
  describe :gemset= do
    describe :default do
      before(:each) do
        GemTemplate::Gemsets.gemset = :default
      end
      
      it "should set @gemset" do
        GemTemplate::Gemsets.gemset.should == :default
      end
    
      it "should set @gemsets" do
        GemTemplate::Gemsets.gemsets.should == {
          :gem_template => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :rspec => "=1.3.1"
            },
            :rspec2 => { :rspec => "=2.3.0" }
          }
        }
      end
    
      it "should set Gems.versions" do
        GemTemplate::Gems.versions.should == {
          :rake => ">0.8.6",
          :rspec => "=1.3.1",
          :externals => "=1.0.2"
        }
      end
    
      it "should set everything to nil if gemset given nil value" do
        GemTemplate::Gemsets.gemset = nil
        GemTemplate::Gemsets.gemset.should == nil
        GemTemplate::Gemsets.gemsets.should == nil
        GemTemplate::Gems.versions.should == nil
      end
    end
    
    describe :rspec2 do
      before(:each) do
        GemTemplate::Gemsets.gemset = "rspec2"
      end
      
      it "should set @gemset" do
        GemTemplate::Gemsets.gemset.should == :rspec2
      end
    
      it "should set @gemsets" do
        GemTemplate::Gemsets.gemsets.should == {
          :gem_template => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :rspec => "=1.3.1"
            },
            :rspec2 => { :rspec => "=2.3.0" }
          }
        }
      end
    
      it "should set Gems.versions" do
        GemTemplate::Gems.versions.should == {
          :rake => ">0.8.6",
          :rspec => "=2.3.0"
        }
      end
    end
    
    describe :nil do
      before(:each) do
        GemTemplate::Gemsets.gemset = nil
      end
      
      it "should set everything to nil" do
        GemTemplate::Gemsets.gemset.should == nil
        GemTemplate::Gemsets.gemsets.should == nil
        GemTemplate::Gems.versions.should == nil
      end
    end
  end
end
