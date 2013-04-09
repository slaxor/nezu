require 'nezu'
module Nezu
  module CLI
    def self.help(*params)
      script_name = File.basename(__FILE__)
      puts %Q(
        Usage:

        "#{script_name} new <appname>" for an app skeleton dir in <appname>
        "#{script_name} run" inside an app dir to start it
        "#{script_name} console" inside an app dir to get an irb shell with your current env loaded

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
      puts %Q(Successfully created App.)
      exit(0)
    end

    def self.run(*params)
      puts %Q(Starting app...)
      require 'nezu/runner'
      Nezu::Runtime.load_config
      if params[0].grep(/--daemon/)
        $stdout=File.open(Nezu.root.join('log', 'nezu.stdout'), File::CREAT|File::WRONLY)
        $stderr=File.open(Nezu.root.join('log', 'nezu.stderr'), File::CREAT|File::WRONLY)
        fork do
          Nezu::Runner.start
        end
      else
        Nezu::Runner.start
      end
      exit(0)
    end

    def self.console(*params)
      puts %Q(Starting console...)
      ARGV.clear
      Nezu::Runtime.load_config
      IRB.start()
    end
  end
end

Nezu::CLI.send(ARGV.shift, ARGV)

