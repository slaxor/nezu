#!/usr/bin/env ruby
#
#
#
require 'bundler'
Bundler.setup

require 'amqp'
require 'json'
require 'debugger' #TODO ... unless Nezu.env.production?
require 'nezu/runtime/worker'
require 'configatron'

$: << './lib'
$: << './app'
$:.unshift(File.expand_path("../../lib", __FILE__))


puts "1"
Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}
puts "2"

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  puts "dir.glob"
  puts yaml_file
  puts "Nezu.env: #{Nezu.env}"
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  puts yaml
  ret = configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
  puts ret
  puts "dir.glob end"
end

puts "[Nezu Runner] starting..."

module Nezu
  class Runner
    def subscriber_class(subscription)
      debugger
      Kernel.const_get(subscription.split('.')[-2].capitalize) #TODO handle namespaces #BUG
    end

    def initialize
      puts "[Nezu Runner] initialize...."
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

