require 'spec_helper'
describe Nezu::Config::Runtime do
  before do
    @orig_pwd = Dir.pwd
    Dir.chdir(File.join(File.dirname(__FILE__), '../../support/sample_project'))
    ActiveRecord::Base.stub!(:establish_connection).and_return(true)
  end

  describe '#new' do
    it 'should look for a config/amqp.yml' do
      File.should_receive(:exist?).with('config/amqp.yml')
      File.should_receive(:exist?).with('config/database.yml')
      Nezu::Config::Runtime.new
    end

    it 'should read config/amqp.yml if it exists' do
      YAML.should_receive(:load_file).with('config/amqp.yml').and_return({})
      YAML.should_receive(:load_file).with('config/database.yml').and_return({})
      Nezu::Config::Runtime.new
    end

    it '' do
    end

    after do
      Dir.chdir(@orig_pwd)
    end
  end
end

