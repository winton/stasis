require 'spec_helper'

describe Stasis::Server do

  before(:all) do
    generate
    @thread = Thread.new do
      Stasis::Server.new($fixture, :server => 'localhost:6379/0')
    end
  end

  after(:all) do
    @thread.kill
  end
  
  it "should change time.html" do
    time = $files['time.html'].split("time")[1].strip
    new_time = Stasis::Server.push(
      :paths => [ 'time.html.haml' ],
      :redis => 'localhost:6379/0',
      :return => true
    )['time.html.haml'].split("time")[1].strip
    time.should_not == new_time
    generate_files
    new_time_from_file = $files['time.html'].split("time")[1].strip
    new_time_from_file.should == new_time
    new_time_from_file.should_not == time
  end
end
