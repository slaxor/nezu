$: << File.expand_path('./lib')
$: << File.expand_path('./app')
$: << File.expand_path('.')

Signal.trap("INT") { Nezu::Runner.stop}
Signal.trap("TERM") { Nezu::Runner.stop}

module Nezu
  class Runner
    # this is the starting point for every application running with "$> nezu run"
    # it get called from cli.rb
    def self.start
      amqp_config = Nezu::Config.amqp[Nezu.env.to_sym]
      AMQP.start(amqp_config.url) do |connection, open_ok|
        Nezu.logger.debug("[Nezu Runner] AMQP connection #{amqp_config.url}")
        channel = AMQP::Channel.new(connection, :auto_recovery => true)
        Nezu.logger.debug("[Nezu Runner] AMQP channel #{channel}")
        Nezu::Runtime::Consumer.descendants.each do |consumer|
          Nezu.logger.debug("[Nezu Runner] Consumer.descendants: ##{consumer.to_s}")
          worker = Nezu::Runtime::Worker.new(channel, consumer.new)
          worker.start
        end
      end
    rescue => e
      Nezu.logger.fatal("#{self.inspect} died restarting")
      Nezu.logger.fatal(e)
      sleep 60
      self.start
    end

    def self.stop(exit_code=0)
      Nezu.logger.info("shutting down #{Nezu.app}")
      AMQP.stop{ EM.stop }
      Nezu.logger.info("done #{Nezu.app}")
      exit(exit_code)
    end

  end
end

Nezu.logger.info("[Nezu Runner] ready")

