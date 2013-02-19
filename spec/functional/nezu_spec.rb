require 'spec_helper'
describe Nezu do
  describe '::env' do
    it 'should be test' do
      Nezu.env.should == 'test'
    end

    it {Nezu.env.should be_an_instance_of Nezu::Env}
    it {Nezu.env.test?.should be_true}
  end
end
