#!/usr/bin/env ruby
#
#
#
Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

require 'bundler'
Bundler.setup

require 'amqp'
require 'json'
require 'debugger' #TODO ... unless Nezu.env.production?
require 'nezu/runtime/worker'

$: << './lib'
$: << './app'
$:.unshift(File.expand_path("../../lib", __FILE__))

module Nezu
  class Runner
    def subscriber_class(subscription)
      Kernel.const_get(subscription.split('.').last.capitalize) #TODO handle namespaces
    end

    def initialize
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        configatron.amqp.subscriptions.each do |subscription|
          worker = Nezu::Runtime::Worker.new(channel, subscription, subscriber_class(subscription).new)
          worker.start
        end
      end

      puts "[boot] Ready"
    end
  end
end

Nezu::Runner.new

