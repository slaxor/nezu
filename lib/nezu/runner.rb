#!/usr/bin/env ruby
#
#
#
Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

require 'bundler'
Bundler.setup

require 'amqp'
require 'debugger' #TODO ... unless Nezu.env.production?

$: << './lib'
$: << './app'
$:.unshift(File.expand_path("../../lib", __FILE__))

require 'dispatcher'

t = Thread.new { EventMachine.run }
sleep(0.5)

connection = AMQP.connect
channel    = AMQP::Channel.new(connection, :auto_recovery => true)
channel.prefetch(1)
configatron.amqp.subscriptions.each do |subscription|
  channel.queue(subscription, :durable => true, :auto_delete => false).subscribe(:ack => true) do |metadata, payload|
    Dispatcher.new(metadata, payload)
  end
end

puts "[boot] Ready"
Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}
t.join


