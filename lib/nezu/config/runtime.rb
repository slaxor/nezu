#### TODO good idea?; If so where to put it then?
module ModuleExtensionForModuleAttribute
  def create_module_attribute(hash)
    hash.each do |key, val|
      #type_cast = Hash.new('to_s').merge({Hash => 'to_hash', Fixnum => 'to_i', Float => 'to_f', Array => 'to_a'})[val.class]
      self.module_eval do
        @#{key} = val
      end
      self.module_eval %Q(
        def self.#{key}
          @#{key}
        end
      )
    end
  end
end

Module.send(:include, ModuleExtensionForModuleAttribute)
####

module Nezu
  module Config
    class Runtime
      def initialize
        Nezu.create_module_attribute :env => ENV['NEZU_ENV'] || 'development'
        Nezu.mattr_accessor :env
        Nezu.env = ENV['NEZU_ENV'] || 'development'

        if File.exist?(File.join('config', 'amqp.yml'))
          Nezu.create_module_attribute :config_amqp => YAML.load_file(File.join('config', 'amqp.yml'))[Nezu.env]
        end

        if File.exist?(File.join('config', 'database.yml'))
          Nezu.create_module_attribute :config_db => YAML.load_file(File.join('config', 'database.yml'))[Nezu.env]
          ActiveRecord::Base.establish_connection(Nezu.config_db)
        end
      end
    end
  end
end

