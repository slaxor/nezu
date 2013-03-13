require 'amqp'
require "bunny"
require 'json'

module Nezu
  module Runtime
    # load everything needed to run the app
    def self.load_config
      Nezu.try(true) { configure_from_yaml('database.yml') }

      begin
        configure_from_yaml('amqp.yml')
      rescue
        Nezu.logger.fatal("[Nezu Runner] no amqp config please create one in config/amqp.yml") unless configatron.amqp.present?
        raise
      end

      if configatron.database.present?
        ActiveRecord::Base.establish_connection(configatron.database.to_hash)
        ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join('log/', 'database.log')))
      end
      require 'nezu/runtime'
      (Dir.glob(Nezu.root.join('app', '**', '*.rb')) + Dir.glob(Nezu.root.join('lib', '**', '*.rb'))).each do |file_name|
        require file_name #Autoload is not thread-safe :(
      end
      Nezu.try {require "config/nezu"}
      Nezu.logger.debug("[Nezu Runner] config loaded")
    end

    private

    def self.configure_from_yaml(yaml_file) #:nodoc:
      yaml = YAML.load_file(Nezu.root.join('config', yaml_file))[Nezu.env]
      configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
    end
  end
end

require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'
require 'nezu/runtime/producer'
require 'nezu/runtime/recipient'

