$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'support', 'lib')))

ENV['NEZU_TEMPLATES'] = "#{Dir.pwd}/spec/support/lib/nezu/generators/application/templates"
ENV['NEZU_ENV'] = 'test'

SPEC_TMP_DIR = "#{Dir.pwd}/spec/support/tmp"

require 'nezu'
require 'amqp'
require "bunny"
require 'json'
require 'nezu/runner'
require 'nezu/runtime/worker'
require 'nezu/runtime/consumer'
require 'nezu/runtime/producer'
require 'nezu/generators'
require 'debugger'
require 'rspec'
require 'rspec/autorun'

