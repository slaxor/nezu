#!/usr/bin/env ruby
#
#
#
#Config
QUEUENAME = 'talkyoo.cashman'
#End of Config


require 'bundler'
Bundler.setup

require 'amqp'
require 'debugger'

$: << './lib'
$: << './app'
$:.unshift(File.expand_path("../../lib", __FILE__))

require 'dispatcher'

t = Thread.new { EventMachine.run }
sleep(0.5)

connection = AMQP.connect
channel    = AMQP::Channel.new(connection, :auto_recovery => true)
channel.prefetch(1)

channel.queue(QUEUENAME, :durable => true, :auto_delete => false).subscribe(:ack => true) do |metadata, payload|
  Dispatcher.new(metadata, payload)
end

puts "[boot] Ready"
Signal.trap("INT") { connection.close { EventMachine.stop } ; exit}
t.join


