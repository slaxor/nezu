#!/usr/bin/env ruby
#
#
#
require 'amqp'
require 'json'
require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'

$: << './lib'
$: << './app'
$:.unshift(File.expand_path("../../lib", __FILE__))


Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

puts "[Nezu Runner] starting..."

module Nezu
  class Runner
    def subscriber_class(subscription)
      debugger
      Object.const_get(subscription.split('.')[-1].capitalize).new #TODO handle namespaces #BUG
    end

    def initialize
      puts "[Nezu Runner] initialize...."
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          puts "Consumer: #{consumer.inspect}"
          worker = Nezu::Runtime::Worker.new(channel, consumer)
          worker.start
        end
      end
    end
  end
end

puts "[boot] Ready"

