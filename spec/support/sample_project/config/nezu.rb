require File.expand_path('../boot', __FILE__)
if defined?(Bundler)
  Bundler.require(:default, Nezu.env)
end

Dir.glob("**/*.rb").each do |f|
  require f
end

require 'producers/pong'

LOGGER = Logger.new('log/SampleProject.log')

