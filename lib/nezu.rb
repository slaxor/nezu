require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'configatron'

module Nezu
  configatron.gem_base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

