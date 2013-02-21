require 'spec_helper'
require 'nezu/runtime/recipient'
describe Nezu::Runtime::Recipient do
  describe '::new' do
    it 'should return the producer class appropriate for the queue' do
      class TestQueue < Nezu::Runtime::Producer;end
      Nezu::Runtime::Recipient.new('test_queue').should == TestQueue
    end

    it 'should bail if the producer class doesn`t exist' do
      lambda { Nezu::Runtime::Recipient.new('non_existant_test_queue') }.should raise_error(Nezu::Runtime::RecipientError)
    end
  end
end

