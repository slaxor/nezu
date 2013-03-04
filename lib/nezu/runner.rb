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
  class CustomLogFormatter
    SEVERITY_TO_COLOR_MAP = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S."
    HOST = %x(hostname).chomp
    APP = File.basename(Dir.pwd)

    def call(severity, time, progname, msg)
      formatted_severity = sprintf("%-5s","#{severity}")
      formatted_time = time.strftime(TIME_FORMAT) << time.usec.to_s[0..2].rjust(3)
      color = SEVERITY_TO_COLOR_MAP[severity]
      if msg.kind_of?(Exception)
        "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{msg.to_s}\n" + 
        msg.backtrace.map do |bt_line|
          "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{bt_line.strip}"
        end.join("\n")
      else
        "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{msg.strip}\n"
      end
    end
  end
  log_target = {
    'development' => STDOUT,
    'test' => nil,
    'production' => File.expand_path(File.join('log/', 'nezu.log'))
  }
  puts "[Nezu] Logger: #{log_target[Nezu.env]}"
  LOGGER = Logger.new(log_target[Nezu.env])
  LOGGER.formatter = CustomLogFormatter.new

  def self.try(&block)
    yield
  rescue Exception => e
    Nezu::LOGGER.warn("[Nezu Runner] Nezu.try failed")
    Nezu::LOGGER.warn(e)
  end
end

Dir.glob(File.join('config', '*.yml')).each do |yaml_file|
  yaml = YAML.load_file(yaml_file)[Nezu.env]
  configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
end

Nezu::LOGGER.info("[Nezu Runner] initializing...")

module Nezu
  class Runner
    def initialize
      Nezu::LOGGER.debug("[Nezu Runner] initialize....")
      Nezu.try {require "config/nezu"}
      AMQP.start(configatron.amqp.url) do |connection, open_ok|
        Nezu::LOGGER.debug("[Nezu Runner] AMQP connection #{configatron.amqp.url}")
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        Nezu::LOGGER.debug("[Nezu Runner] AMQP channel #{channel}")
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          Nezu::LOGGER.debug("[Nezu Runner] Consumer.descendants: ##{consumer.to_s}")
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
      end
    #rescue => e
      #Nezu::LOGGER.error(e)
      #self.class.new
    end
  end
end

Nezu::LOGGER.info("[Nezu Runner] ready")

