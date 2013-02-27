require 'spec_helper'
require 'nezu/runtime/consumer'
describe Nezu::Runtime::Consumer do
  describe '::descendants' do
    it 'should return a list of heirs' do
      class Consumer1 < Nezu::Runtime::Consumer;end
      class Consumer2 < Nezu::Runtime::Consumer;end
      Nezu::Runtime::Consumer.descendants.should =~ [Consumer2, Consumer1]
    end
  end

  describe '#handle_message' do
    before do
      class Consumer1 < Nezu::Runtime::Consumer;end
      @consumer = Consumer1.new
    end

    it 'should ' do
      reply_to = 'foo'
      Nezu::Runtime::Recipient.should.receive(:new).with(reply_to)
      @consumer.handle_message('{"meta": "not_used"}', %Q{"__action" : "bar", "__reply_to": #{reply_to}})
    end
  end

  describe '::queue_name' do
    it 'should return its translated class name' do
      module JustAModule;class Consumer1<Nezu::Runtime::Consumer;end;end
      JustAModule::Consumer1.queue_name.should == 'just_a_module.consumer1'
    end

    it 'should use the queue_prefix if its set' do
      configatron.amqp.queue_prefix = 'the_prefix'
      module JustAModule;class ConsumerWithPrefix<Nezu::Runtime::Consumer;end;end
      JustAModule::ConsumerWithPrefix.queue_name.should == 'the_prefix.just_a_module.consumer_with_prefix'
      configatron.amqp.queue_prefix = nil
    end

    it 'should use the queue_postfix if its set' do
      configatron.amqp.queue_postfix = 'the_postfix'
      module JustAModule;class ConsumerWithPostfix<Nezu::Runtime::Consumer;end;end
      JustAModule::ConsumerWithPostfix.queue_name.should == 'just_a_module.consumer_with_postfix.the_postfix'
      configatron.amqp.queue_postfix = nil
    end
  end

  describe '::queue_name=' do
    it 'should use queue_name if it was set' do
      module JustAModule;class ConsumerWithCustomQueue<Nezu::Runtime::Consumer;end;end
      JustAModule::ConsumerWithCustomQueue.queue_name = 'abc.123'
      JustAModule::ConsumerWithCustomQueue.queue_name.should == 'abc.123'
    end
  end
end
