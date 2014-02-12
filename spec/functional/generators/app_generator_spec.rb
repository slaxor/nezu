require 'spec_helper'
require 'nezu/generators'
require 'nezu/generators/application/app_generator'

describe Nezu::Generators::Application::AppGenerator do
  describe '#new' do
    before do
      @app = Nezu::Generators::Application::AppGenerator.new('/blah/foo')
    end

    it 'should have a destination_root' do
      Nezu::Config.destination_root.should == '/blah/foo'
    end

    it 'should have an app_name' do
      Nezu::Config.app_name.should == 'foo'
    end

    it 'should have a scope' do
      Nezu::Config.name_space.should == Foo
      Foo.class.should be_a(Module)
    end
  end

  describe '#generate!' do
    before do
      @my_dest_root = "#{SPEC_TMP_DIR}/foo_#{rand(35**4).to_s(35)}"
      @app = Nezu::Generators::Application::AppGenerator.new(@my_dest_root)
    end

    it 'should create the destination_root dir' do
      @app.generate!
      File.exist?(@my_dest_root).should be_true
    end

    it 'should create the amqp.yml' do
      @app.generate!
      File.exist?(File.join(@my_dest_root, 'config', 'amqp.yml')).should be_true
    end

    it 'should bail out if the destination_root already exists' do
      @app.generate!
      @app = Nezu::Generators::Application::AppGenerator.new(@my_dest_root)
      lambda {@app.generate!}.should raise_error(Nezu::Generators::Application::AppGeneratorError, "\"#{@my_dest_root}\" already exists")
    end

    after do
      FileUtils.rm_rf(@my_dest_root)
    end
  end
end

