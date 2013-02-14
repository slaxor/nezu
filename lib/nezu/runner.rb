#!/usr/bin/env ruby
#
#
#
#Config
#QUEUENAME = 'talkyoo.cashman'
amqp_file = File.join('config', 'amqp.yml')
amqp = YAML.load_file(amqp_file)[Nezu.env] if File.exists?(amqp_file)
configatron.configure_from_hash(amqp: amqp)


amqp = YAML.load_file(File.join('config', 'amqp.yml'))[Nezu.env]
configatron.configure_from_hash(amqp: amqp)

#End of Config

Nezu::Config::Runtime.amqp
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

channel.queue(CONFIG.amqp['subscriptions'], :durable => true, :auto_delete => false).subscribe(:ack => true) do |metadata, payload|
  Dispatcher.new(metadata, payload)
end

puts "[boot] Ready"
Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}
t.join


