require 'spec_helper'

describe GemTemplate::Gems do
  
  describe :activate do
    before(:each) do
      GemTemplate::Gems.configs = [
        "#{$root}/spec/fixtures/gemsets.yml"
      ]
      GemTemplate::Gems.gemset = nil
      GemTemplate::Gems.testing = true
    end
    
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
  
  describe :gemset= do
    before(:each) do
      GemTemplate::Gems.configs = [
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
    
    describe :default do
      before(:each) do
        GemTemplate::Gems.gemset = :default
      end
      
      it "should set @gemset" do
        GemTemplate::Gems.gemset.should == :default
      end
    
      it "should set @gemsets" do
        GemTemplate::Gems.gemsets.should == {
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
        GemTemplate::Gems.gemset = nil
        GemTemplate::Gems.gemset.should == nil
        GemTemplate::Gems.gemsets.should == nil
        GemTemplate::Gems.versions.should == nil
      end
    end
    
    describe :rspec2 do
      before(:each) do
        GemTemplate::Gems.gemset = "rspec2"
      end
      
      it "should set @gemset" do
        GemTemplate::Gems.gemset.should == :rspec2
      end
    
      it "should set @gemsets" do
        GemTemplate::Gems.gemsets.should == {
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
        GemTemplate::Gems.gemset = nil
      end
      
      it "should set everything to nil" do
        GemTemplate::Gems.gemset.should == nil
        GemTemplate::Gems.gemsets.should == nil
        GemTemplate::Gems.versions.should == nil
      end
    end
  end
  
  describe :reload_gemspec do
    before(:all) do
      GemTemplate::Gems.configs = [
        "#{$root}/spec/fixtures/gemsets.yml"
      ]
      GemTemplate::Gems.gemset = :default
    end
  
    before(:each) do
      @gemspec_path = "#{$root}/gem_template.gemspec"
      @gemspec = File.read(@gemspec_path)
      yml = File.read("#{$root}/spec/fixtures/gemspec.yml")
      File.stub!(:read).and_return yml
      GemTemplate::Gems.reload_gemspec
    end
  
    it "should populate @gemspec" do
      GemTemplate::Gems.gemspec.hash.should == {
        "name" => "name",
        "version" => "0.1.0",
        "authors" => ["Author"],
        "email" => "email@email.com",
        "homepage" => "http://github.com/author/name",
        "summary" => "Summary",
        "description" => "Description",
        "dependencies" => ["rake"],
        "development_dependencies" => ["rspec"]
       }
    end
  
    it "should create methods from keys of @gemspec" do
      GemTemplate::Gems.gemspec.name.should == "name"
      GemTemplate::Gems.gemspec.version.should == "0.1.0"
      GemTemplate::Gems.gemspec.authors.should == ["Author"]
      GemTemplate::Gems.gemspec.email.should == "email@email.com"
      GemTemplate::Gems.gemspec.homepage.should == "http://github.com/author/name"
      GemTemplate::Gems.gemspec.summary.should == "Summary"
      GemTemplate::Gems.gemspec.description.should == "Description"
      GemTemplate::Gems.gemspec.dependencies.should == ["rake"]
      GemTemplate::Gems.gemspec.development_dependencies.should == ["rspec"]
    end
  
    it "should produce a valid gemspec" do
      gemspec = eval(@gemspec, binding, @gemspec_path)
      gemspec.validate.should == true
    end
  end
end
