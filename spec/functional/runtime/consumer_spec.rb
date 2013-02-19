require 'nezu/runtime/consumer'
describe Nezu::Runtime::Consumer do
  describe '::descendants' do
    it 'should return a list of heirs' do
      class Consumer1 < Nezu::Runtime::Consumer;end
      class Consumer2 < Nezu::Runtime::Consumer;end
      Nezu::Runtime::Consumer.descendants.should == [Consumer2, Consumer1]
    end
  end

  describe '::to_queue_name' do
    it 'should return its translated class name' do
      module JustAModule;class Consumer1<Nezu::Runtime::Consumer;end;end
      JustAModule::Consumer1.to_queue_name.should == 'just_a_module.consumer1'
    end
  end
end
