require 'spec_helper'
require 'nezu/generators'
include Nezu::Generators

describe Nezu::Generators do
  describe '#template_to' do
    it 'should create a (parsed) copy in the app dir' do
      template_to('test_file')
      File.exists?(File.join(configatron.destination_root, '/test_file')).should be_true
    end

    it 'should parse .tt files using erb' do
      template_to('test_file')
      File.read(File.join(configatron.destination_root, '/test_file')).match(/Hi there/).should_not be_nil
    end

    after do
      %x(rm -rf #{configatron.destination_root})
    end
  end

  describe '#find_template' do
    it 'should return nil if file could not be found in paths' do
      find_template('non_existant_file').should be_nil
    end

    it 'should return the first found candidate in paths' do
      find_template('test_file').should match('spec/support/lib/nezu/generators/application/templates/test_file.tt')
    end

    it 'should also return a candidate with no suffix' do
      find_template('test_file_without_suffix').should match('spec/support/lib/nezu/generators/application/templates/test_file_without_suffix')
    end
  end
end

