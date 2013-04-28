require 'spec_helper'
require 'stasis/dev_mode'

describe Stasis::DevMode do
  let(:sample_app_dir) { File.expand_path(File.join(File.path(__FILE__), '..', '..', 'sample_app')) }
  let(:public_dir)     { 'custom_public' }
  let(:stasis)         { Stasis::DevMode.new(sample_app_dir, :public => public_dir) }

  after(:each) do
    FileUtils.rm_r Dir.glob(File.join(sample_app_dir, '*'))
  end

  context 'watching directory changes' do
    it 'ignores changes in the destination directory' do
      stasis.listener.directories_records.first.ignoring_patterns.should include Regexp.new(public_dir)
    end

    it 'detects chagnes in the destingation directory' do
      thread = Thread.new { stasis.run }
      sleep 1
      `echo 'Hello, world!' >> #{File.join sample_app_dir, 'test.txt'}`
      sleep 1
      File.exists?(File.join(sample_app_dir, public_dir, 'test.txt')).should be_true
      thread.kill
    end
  end

end
