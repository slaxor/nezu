require 'nezu/runtime/consumer'
describe Nezu::Runtime::Consumer do
  describe '::descendants' do
    it 'should return a list of heirs' do
      class Consumer1 < Nezu::Runtime::Consumer;end
      class Consumer2 < Nezu::Runtime::Consumer;end
      Nezu::Runtime::Consumer.descendants.should =~ [Consumer2, Consumer1]
    end
  end

  describe '::to_queue_name' do
    it 'should return its translated class name' do
      module JustAModule;class Consumer1<Nezu::Runtime::Consumer;end;end
      JustAModule::Consumer1.to_queue_name.should == 'just_a_module.consumer1'
    end

    it 'should use the queue_prefix if its set' do
      configatron.amqp.queue_prefix = 'the_prefix'
      module JustAModule;class Consumer1<Nezu::Runtime::Consumer;end;end
      JustAModule::Consumer1.to_queue_name.should == 'the_prefix.just_a_module.consumer1'
      configatron.amqp.queue_prefix = nil
    end

    it 'should use the queue_postfix if its set' do
      configatron.amqp.queue_postfix = 'the_postfix'
      module JustAModule;class Consumer1<Nezu::Runtime::Consumer;end;end
      JustAModule::Consumer1.to_queue_name.should == 'just_a_module.consumer1.the_postfix'
      configatron.amqp.queue_postfix = nil
    end
  end

  describe '::queue_name=' do
    it 'should use queue_name if it was set' do
      module JustAModule;class Consumer2<Nezu::Runtime::Consumer; queue_name = 'abc.123';end;end
      JustAModule::Consumer2.to_queue_name.should == 'abc.123'
    end
  end
end
