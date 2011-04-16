require 'spec_helper'

describe Stasis do
  
  it "should" do
    stasis = Stasis.new("#{$root}/spec/fixtures/project")
    stasis.generate
  end
end