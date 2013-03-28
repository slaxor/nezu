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
      if configatron.database.send(Nezu.env).database.present? && !Class.const_defined?(:Rails)
        require configatron.database.send(Nezu.env).adapter
        ActiveRecord::Base.establish_connection(configatron.database.send(Nezu.env.to_sym).to_hash)
        ActiveRecord::Base.logger = Logger.new(Nezu.root.join('log/', 'database.log'))
      end

      req_files = Dir.glob(Nezu.root.join('app', 'consumers', '*.rb'))
      req_files += Dir.glob(Nezu.root.join('app', 'producers', '*.rb'))
      unless Class.const_defined?(:Rails)
        req_files += Dir.glob(Nezu.root.join('app', 'models', '*.rb'))
        req_files += Dir.glob(Nezu.root.join('lib', '**', '*.rb'))
      end
       req_files.each do |file_name|
        require file_name #Autoload is not thread-safe :(
      end
      Nezu.try {require "config/nezu"}
      Nezu.logger.debug("[Nezu Runner] config loaded")
      Nezu.logger.debug(configatron.amqp)
    end

    module Common

      # creates a class method ::queue_name with a queue name derived from the class name and pre- and posfixes.
      # e.g if a classes name is Foo the queue_name will be "your_prefix.foo.your_postfix"
      # to avoid naming conflicts it is also possible to scope the class in modules "Producers" or "Consumers"
      # so a somthing like:
      #:code
      # module Producers
      #   class FooBar < Nezu::Runtime::Producer
      #   end
      # end
      #
      # will result in a queue "your_prefix.foo_bar.your_postfix"
      # the same goes for module "Consumers". This is especially useful if you need a consumer and a producer
      # on the same queue
      #
      def inherited(subclass)
        subclass.class_eval {cattr_accessor :queue_name} #:exchange_name?
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.send(Nezu.env.to_sym).queue_prefix}." unless configatron.amqp.send(Nezu.env.to_sym).queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/^(Producers|Consumers)::/, '').gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.send(Nezu.env.to_sym).queue_postfix}" unless configatron.amqp.send(Nezu.env.to_sym).queue_postfix.nil?
        subclass.queue_name
      end

      def descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end
    end

    private

    def self.configure_from_yaml(yaml_file) #:nodoc:
      yaml = YAML.load_file(Nezu.root.join('config', yaml_file))
      configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
    end
  end
end

require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'
require 'nezu/runtime/producer'
require 'nezu/runtime/recipient'

