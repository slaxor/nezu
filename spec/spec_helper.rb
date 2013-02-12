$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'support', 'lib')))

ENV['NEZU_TEMPLATES'] = "#{Dir.pwd}/spec/support/lib/nezu/generators/application/templates"

SPEC_TMP_DIR = "#{Dir.pwd}/spec/support/tmp"

require 'nezu'
require 'nezu/config/runtime'
require 'debugger'
require 'rspec'
require 'rspec/autorun'

