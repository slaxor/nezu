require 'spec_helper'
describe Nezu::Config::Runtime do
  before do
    @orig_pwd = Dir.pwd
    Dir.chdir(File.join(File.dirname(__FILE__), '../../support/sample_project'))
    ActiveRecord::Base.stub!(:establish_connection).and_return(true)
  end

  it '' do
  end

  after do
    Dir.chdir(@orig_pwd)
  end
end

