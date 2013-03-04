require 'bundler'
Bundler.setup

require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'configatron'
module Nezu
  configatron.gem_base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

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

  class Error < Exception
    def new(e,msg)
      Nezu::LOGGER.error(e.to_s)
      e.backtrace.each {|bt_line| Nezu::LOGGER.error(bt_line)}
    end
  end
end

require 'debugger' unless Nezu.env.production?

