require 'optparse'
require 'nezu'
module Nezu
  module CLI
    def self.new(params={})
      puts %Q(Creating application dir in "#{params[:app]}")
      require 'nezu/generators'
      app = Nezu::Generators::Application::AppGenerator.new(params[:app])
      app.generate!
      puts %Q(Successfully created App.)
      exit(0)
    end

    def self.run(params={})
      puts %Q(Starting app...)
      require 'nezu/runner'
      Nezu::Runtime.load_config
      if params[:daemon]
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

    def self.console(params={})
      puts %Q(Starting console...)
      Nezu::Runtime.load_config
      IRB.start()
    end
  end
end

begin
  command = ARGV.shift
  options = {}

  if command == 'new'
    options[:app] = ARGV.shift
  else

    optparse = OptionParser.new do|opts|
      opts.program_name = "#{File.basename($0, '.*')} COMMAND:=run|console|new"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end
      if command == 'run'
        options[:daemon] = false
        opts.on( '-d', '--daemon', 'Run as a background process' ) do
          options[:daemon] = true
        end

      end

      opts.on( '-E <ENV>', '--env <ENV>', 'Start the app with the given environment' ) do |env|
        options[:env] = env
        Nezu.env = Nezu::Env.new(env)
      end
    end

    optparse.parse!
  end

  require 'debugger' if Nezu.env.development? || Nezu.env.test?

  Nezu::CLI.send(command, options)
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
  puts optparse
end
