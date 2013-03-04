require File.expand_path('../boot', __FILE__)
if defined?(Bundler)
  Bundler.require(:default, Nezu.env)
end

Dir.glob("**/*.rb").each do |f|
  require f
end

LOGGER = Logger.new('log/SampleProject.log')

