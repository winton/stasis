require 'spec_helper'

describe GemTemplate::Gems do
  
  before(:each) do
    @old_config = GemTemplate::Gems.config
    
    GemTemplate::Gems.config.gemspec = "#{$root}/spec/fixtures/gemspec.yml"
    GemTemplate::Gems.config.gemsets = [
      "#{$root}/spec/fixtures/gemsets.yml"
    ]
    GemTemplate::Gems.config.warn = true
    
    GemTemplate::Gems.gemspec true
    GemTemplate::Gems.gemset = nil
  end
  
  after(:each) do
    GemTemplate::Gems.config = @old_config
  end
  
  describe :activate do
    it "should activate gems" do
      GemTemplate::Gems.stub!(:gem)
      GemTemplate::Gems.should_receive(:gem).with('rspec', '=1.3.1')
      GemTemplate::Gems.should_receive(:gem).with('rake', '=0.8.7')
      GemTemplate::Gems.activate :rspec, 'rake'
    end
  end
  
  describe :gemset= do
    before(:each) do
      GemTemplate::Gems.config.gemsets = [
        {
          :name => {
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
          :name => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :mysql => "=2.8.1",
              :rspec => "=1.3.1"
            },
            :rspec2 => {
              :mysql2 => "=0.2.6",
              :rspec => "=2.3.0"
            },
            :solo => nil
          }
        }
      end
    
      it "should set Gems.versions" do
        GemTemplate::Gems.versions.should == {
          :externals => "=1.0.2",
          :mysql => "=2.8.1",
          :rake => ">0.8.6",
          :rspec => "=1.3.1"
        }
      end
      
      it "should return proper values for Gems.dependencies" do
        GemTemplate::Gems.dependencies.should == [ :rake, :mysql ]
        GemTemplate::Gems.development_dependencies.should == []
      end
      
      it "should return proper values for Gems.gemset_names" do
        GemTemplate::Gems.gemset_names.should == [ :default, :rspec2, :solo ]
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
          :name => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :mysql => "=2.8.1",
              :rspec => "=1.3.1"
            },
            :rspec2 => {
              :mysql2=>"=0.2.6",
              :rspec => "=2.3.0"
            },
            :solo => nil
          }
        }
      end
    
      it "should set Gems.versions" do
        GemTemplate::Gems.versions.should == {
          :mysql2 => "=0.2.6",
          :rake => ">0.8.6",
          :rspec => "=2.3.0"
        }
      end
      
      it "should return proper values for Gems.dependencies" do
        GemTemplate::Gems.dependencies.should == [ :rake, :mysql2 ]
        GemTemplate::Gems.development_dependencies.should == []
      end
      
      it "should return proper values for Gems.gemset_names" do
        GemTemplate::Gems.gemset_names.should == [ :default, :rspec2, :solo ]
      end
    end
    
    describe :solo do
      before(:each) do
        GemTemplate::Gems.gemset = :solo
      end
      
      it "should set @gemset" do
        GemTemplate::Gems.gemset.should == :solo
      end
    
      it "should set @gemsets" do
        GemTemplate::Gems.gemsets.should == {
          :name => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :mysql => "=2.8.1",
              :rspec => "=1.3.1"
            },
            :rspec2 => {
              :mysql2=>"=0.2.6",
              :rspec => "=2.3.0"
            },
            :solo => nil
          }
        }
      end
    
      it "should set Gems.versions" do
        GemTemplate::Gems.versions.should == {:rake=>">0.8.6"}
      end
      
      it "should return proper values for Gems.dependencies" do
        GemTemplate::Gems.dependencies.should == [:rake]
        GemTemplate::Gems.development_dependencies.should == []
      end
      
      it "should return proper values for Gems.gemset_names" do
        GemTemplate::Gems.gemset_names.should == [ :default, :rspec2, :solo ]
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
  
  describe :gemset_from_loaded_specs do
    before(:each) do
      Gem.stub!(:loaded_specs)
    end
    
    it "should return the correct gemset for name gem" do
      Gem.should_receive(:loaded_specs).and_return({ "name" => nil })
      GemTemplate::Gems.send(:gemset_from_loaded_specs).should == :default
    end
    
    it "should return the correct gemset for name-rspec gem" do
      Gem.should_receive(:loaded_specs).and_return({ "name-rspec2" => nil })
      GemTemplate::Gems.send(:gemset_from_loaded_specs).should == :rspec2
    end
  end
  
  describe :reload_gemspec do
    it "should populate @gemspec" do
      GemTemplate::Gems.gemspec.hash.should == {
        "name" => "name",
        "version" => "0.1.0",
        "authors" => ["Author"],
        "email" => "email@email.com",
        "homepage" => "http://github.com/author/name",
        "summary" => "Summary",
        "description" => "Description",
        "dependencies" => [
          "rake",
          { "default" => [ "mysql" ] },
          { "rspec2" => [ "mysql2" ] }
        ],
        "development_dependencies" => nil
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
      GemTemplate::Gems.gemspec.dependencies.should == [
        "rake",
        { "default" => ["mysql"] },
        { "rspec2" => [ "mysql2" ] }
      ]
      GemTemplate::Gems.gemspec.development_dependencies.should == nil
    end
  
    it "should produce a valid gemspec" do
      GemTemplate::Gems.gemset = :default
      gemspec = File.expand_path("../../../gem_template.gemspec", __FILE__)
      gemspec = eval(File.read(gemspec), binding, gemspec)
      gemspec.validate.should == true
    end
  end
end
