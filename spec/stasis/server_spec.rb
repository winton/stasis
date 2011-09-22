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

  it "should pass params" do
    params = Stasis::Server.push(
      :paths => [ 'params.html.haml' ],
      :params => { :test => true },
      :redis => 'localhost:6379/0',
      :return => true
    )['params.html.haml'].split("params")[1].strip
    eval(params).should == { :test => true }
  end

  it "should expire after ttl" do
    time = Stasis::Server.push(
      :paths => [ 'time.html.haml' ],
      :redis => 'localhost:6379/0',
      :return => true,
      :ttl => 1,
      :write => false
    )['time.html.haml'].split("time")[1].strip
    time2 = Stasis::Server.push(
      :paths => [ 'time.html.haml' ],
      :redis => 'localhost:6379/0',
      :return => true,
      :write => false
    )['time.html.haml'].split("time")[1].strip
    time.should == time2
    sleep 2
    time3 = Stasis::Server.push(
      :paths => [ 'time.html.haml' ],
      :redis => 'localhost:6379/0',
      :return => true,
      :write => false
    )['time.html.haml'].split("time")[1].strip
    time2.should_not == time3
  end
end
