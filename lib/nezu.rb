require 'bundler'
Bundler.setup

require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'configatron'

module Nezu
  configatron.gem_base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LOGGER = Logger.new("log/nezu.log")
  def self.env
    Env.new(ENV['NEZU_ENV']||'development')
  end

  class Env < String
    def method_missing(meth, params=nil)
      meth.to_s.sub(/\?$/, '') == self
    end

    def respond_to?(meth, params=nil)
      !!meth.to_s.match(/\?$/)
    end
  end
end

require 'debugger' unless Nezu.env.production?

