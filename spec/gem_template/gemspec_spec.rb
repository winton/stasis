require 'spec_helper'

describe GemTemplate::Gemspec do
  
  before(:all) do
    GemTemplate::Gemsets.configs = [
      "#{$root}/spec/fixtures/gemsets.yml"
    ]
    GemTemplate::Gemsets.gemset = :default
  end
  
  before(:each) do
    @gemspec_path = "#{$root}/gem_template.gemspec"
    @gemspec = File.read(@gemspec_path)
    yml = File.read("#{$root}/spec/fixtures/gemspec.yml")
    File.stub!(:read).and_return yml
    GemTemplate::Gemspec.reload
  end
  
  after(:all) do
    GemTemplate::Gemspec.reload
  end
  
  it "should populate @data" do
    GemTemplate::Gemspec.data.should == {
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
  
  it "should create methods from keys of @data" do
    GemTemplate::Gemspec.name.should == "name"
    GemTemplate::Gemspec.version.should == "0.1.0"
    GemTemplate::Gemspec.authors.should == ["Author"]
    GemTemplate::Gemspec.email.should == "email@email.com"
    GemTemplate::Gemspec.homepage.should == "http://github.com/author/name"
    GemTemplate::Gemspec.summary.should == "Summary"
    GemTemplate::Gemspec.description.should == "Description"
    GemTemplate::Gemspec.dependencies.should == ["rake"]
    GemTemplate::Gemspec.development_dependencies.should == ["rspec"]
  end
  
  it "should produce a valid gemspec" do
    gemspec = eval(@gemspec, binding, @gemspec_path)
    gemspec.validate.should == true
  end
end