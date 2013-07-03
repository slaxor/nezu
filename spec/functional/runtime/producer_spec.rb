require 'spec_helper'
require 'nezu/runtime/producer'
describe Nezu::Runtime::Producer do
  before do
    #Bunny.stub!(:new).and_return(AlwaysHappy.new)
  end

  describe '::push!' do
    it 'should create a new message on the server' do
      configatron.amqp.send(Nezu.env.to_sym).url = 'amqp://127.0.0.1'
      Bunny.should_receive(:new).with(configatron.amqp.send(Nezu.env.to_sym).url, :threaded=>false).and_return(AlwaysHappy.new)
      module ExampleProducers;class MyQueue<Nezu::Runtime::Producer;end;end
      ExampleProducers::MyQueue.push!(:foo => 'bar')
    end

    it 'should close its connection' do
      configatron.amqp.send(Nezu.env.to_sym).url = 'amqp://127.0.0.1'
      Bunny::Session.any_instance.should_receive(:close)
      module ExampleProducers;class MyQueue<Nezu::Runtime::Producer;end;end
      ExampleProducers::MyQueue.push!(:foo => 'bar')
    end
  end

  describe '::queue_name' do
    it 'should create a new message on the server' do
      module ExampleProducers;class MyQueue<Nezu::Runtime::Producer;end;end
      ExampleProducers::MyQueue.queue_name.should == 'example_producers.my_queue'
    end
  end
end

