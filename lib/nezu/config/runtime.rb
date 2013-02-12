module Nezu
  module Config
    class Runtime
      include Nezu::Config

      #def initialize
      #Nezu.create_module_attribute :env => ENV['NEZU_ENV'] || 'development'
      #Nezu.mattr_accessor :env
      #Nezu.env = ENV['NEZU_ENV'] || 'development'

      #if File.exist?(File.join('config', 'amqp.yml'))
      #Nezu.create_module_attribute :config_amqp => YAML.load_file(File.join('config', 'amqp.yml'))[Nezu.env]
      #end

      #if File.exist?(File.join('config', 'database.yml'))
      #Nezu.create_module_attribute :config_db => YAML.load_file(File.join('config', 'database.yml'))[Nezu.env]
      #ActiveRecord::Base.establish_connection(Nezu.config_db)
      #end
    end
  end
end

