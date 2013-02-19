#!/usr/bin/env ruby
#
#
#
require 'amqp'
require 'json'
require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'

$: << File.expand_path('./lib')
$: << File.expand_path('./app')
$: << File.expand_path('.')
#$:.unshift(File.expand_path("../../lib", __FILE__))


Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}

require 'config/boot'

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

puts "[Nezu Runner] starting..."

module Nezu
  class Runner
    def initialize
      puts "[Nezu Runner] initialize...."
      require 'config/application'
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        puts "schleife"
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        puts Nezu::Runtime::Consumer.descendants.size
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          puts "Consumer: #{consumer.inspect}"
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
      end
    end
  end
end

puts "[boot] Ready"

