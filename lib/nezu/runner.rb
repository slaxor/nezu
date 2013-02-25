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

Nezu.try {require 'config/boot'}

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

puts "[Nezu Runner] starting..."

module Nezu
  class Runner
    def initialize
      puts "[Nezu Runner] initialize...."
      Nezu.try {require 'config/application'}
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
      end
    end
  end
end

puts "[Nezu Runner] Ready"

