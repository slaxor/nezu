#!/usr/bin/env ruby

$: << File.expand_path('./lib')
$: << File.expand_path('./app')
$: << File.expand_path('.')

Signal.trap("INT") { Nezu::Runner.connection.close { EventMachine.stop } ; exit}

module Nezu
  class Runner
    # this is the starting point for every application running with "$> nezu run"
    # it get called from cli.rb
    def initialize
      Nezu.load_config
      Nezu.logger.debug("[Nezu Runner] initialize....")
      Nezu.try {require "config/nezu"}
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        Nezu.logger.debug("[Nezu Runner] AMQP connection #{configatron.amqp.url}")
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        Nezu.logger.debug("[Nezu Runner] AMQP channel #{channel}")
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          Nezu.logger.debug("[Nezu Runner] Consumer.descendants: ##{consumer.to_s}")
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
        @@connection = connection
      end
    rescue => e
      Nezu.logger.fatal("#{self.inspect} died restarting")
      Nezu.logger.fatal(e)
      sleep 0.5
      self.class.new
    end

    def self.connection
      @@connection
    end
  end
end

Nezu.logger.info("[Nezu Runner] ready")

