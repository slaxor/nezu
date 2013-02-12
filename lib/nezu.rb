require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'nezu/config'
module Nezu
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  #def self.create_module_attribute(hash)
    #hash.each do |key, value|
      #singleton_class.send(:define_method, key) { value }
    #end
  #end
end

