require 'nezu/runtime/consumer'
describe Nezu::Runtime::Consumer do
  describe '::descendants' do
    it 'should return a list of heirs' do
      class Consumer1 < Nezu::Runtime::Consumer;end
      class Consumer2 < Nezu::Runtime::Consumer;end
      Nezu::Runtime::Consumer.descendants.should == [Consumer2, Consumer1]
    end
  end
end
