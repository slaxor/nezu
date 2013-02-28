#!/usr/bin/env ruby
#
#
#
require 'amqp'
require "bunny"
require 'json'
require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'
require 'nezu/runtime/producer'
require 'nezu/runtime/recipient'

$: << File.expand_path('./lib')
$: << File.expand_path('./app')
$: << File.expand_path('.')


Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}

module Nezu
  def self.try(&block)
    yield
  rescue Exception => e
    nil
  end
end

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

puts "[Nezu Runner] initializing..."

module Nezu
  class Runner
    def initialize
      puts "[Nezu Runner] initialize...."
      Nezu.try {require "config/nezu"}
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        puts "[Nezu Runner] AMQP connection #{configatron.amqp.url}"
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        puts "[Nezu Runner] AMQP channel #{channel}"
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          puts "[Nezu Runner] Consumer.descendants: ##{consumer.to_s}"
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
      end
    rescue => e
      Nezu::LOGGER.crit(e)
    end
  end
end

puts "[Nezu Runner] ready"

