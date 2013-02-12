require File.expand_path('../boot', __FILE__)
if defined?(Bundler)
  Bundler.require(:default, Nezu.env)
end

module SampleProject
  class Application < Nezu::Runtime
  end
end

