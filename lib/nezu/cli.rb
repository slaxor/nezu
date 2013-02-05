require 'rbconfig'
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

    def self.new(appname)
      puts "Creating application dir in #{appname}"
      require 'nezu/generators'
      Nezu::Generators::Application.new(ARGV)
      exit(0)
    end

    def self.run
      puts "Starting app..."
      require 'nezu/runner'
      Nezu::Runner.new(ARGV)
      exit(0)
    end
  end
end


Nezu::CLI.send(ARGV.shift, ARGV)





