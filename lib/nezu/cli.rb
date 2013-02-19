Signal.trap("INT") { puts; exit(1) }

module Nezu
  module CLI
    def self.help(*params)
      script_name = File.basename(__FILE__)
      puts %Q(
        Usage:

        "#{script_name} new <appname>" for an app skeleton dir in <appname>
        "#{script_name} run" inside an app dir to start it

      ).gsub(/^\s*/, '')
      exit(1)
    end

    def self.new(*params)
      amqp_scope = params[0].grep(/--amqp_scope/)[0].match(/=(\S*)/)[1] rescue nil
      configatron.amqp_scope = amqp_scope if amqp_scope
      puts %Q(Creating application dir in "#{params[0][0]}")
      require 'nezu/generators'
      app = Nezu::Generators::Application::AppGenerator.new(params[0][0])
      app.generate!
      exit(0)
    end

    def self.run(*params)
      puts %Q(Starting app...)
      require 'nezu/runner'
      Nezu::Runner.new
      exit(0)
    end
  end
end


Nezu::CLI.send(ARGV.shift, ARGV)





