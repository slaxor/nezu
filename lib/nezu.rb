require 'bundler'
Bundler.setup

require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'configatron'
require 'term/ansicolor'
require 'nezu/runtime'

module Nezu
  mattr_accessor :logger

  GEM_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  #used by Nezu.env and Nezu.env.developent? etc.
  class Env < String
    def method_missing(meth, params=nil) #:nodoc:
      env = meth.to_s.sub(/\?$/, '')
      super if env == meth.to_s # doesn't end on "?" ? try parents.
      env == self
    end

    def respond_to?(meth, params=nil) #:nodoc:
      !!meth.to_s.match(/\?$/)
    end
  end

  class Root < String
    APP_PATH = self.new(File.expand_path(Dir.pwd))

    # you can do Nezu.root.join('path', 'to', 'your', 'stuff') and get the
    # absolute path of your stuff
    def join(*params)
      File.join(APP_PATH, params)
    end
  end

  # the generic exception class
  class Error < Exception
    def new(e,msg)
      Nezu.logger.error(e.to_s)
      e.backtrace.each {|bt_line| Nezu.logger.error(bt_line)}
    end
  end

  # all these nice colorful log entries are created here
  # if you don`t like them just override its #call method
  class CustomLogFormatter
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S."
    HOST = %x(hostname).chomp
    APP = File.basename(Dir.pwd)

    String.send(:include, Term::ANSIColor)

    def call(severity, time, progname, msg)
      @severity = severity
      @time = time
      @progname = progname
      @msg = msg
      formatted_msg
    end

    private

    def formatted_severity
      {
        'DEBUG'   => 'DEBUG'.blue,
        'INFO'    => ' INFO'.green,
        'WARN'    => ' WARN'.yellow,
        'ERROR'   => 'ERROR'.intense_red,
        'FATAL'   => 'FATAL'.intense_white.on_red,
        'ANY'     => '  ANY'.black.on_white
      }[@severity]
    end

    def formatted_progname
    end

    def formatted_msg
      formatted_time = @time.strftime(TIME_FORMAT) << @time.usec.to_s[0..2].rjust(3)
      if @msg.kind_of?(Exception)
        "#{formatted_time} #{HOST} #{APP}[#{$$}][#{formatted_severity}] #{@msg.inspect}\n" +
        @msg.backtrace.map do |bt_line|
          "#{formatted_time} #{HOST} #{APP}[#{$$}][#{formatted_severity}] #{bt_line}\n"
        end.join
      elsif @msg.kind_of?(String)
        "#{formatted_time} #{HOST} #{APP}[#{$$}][#{formatted_severity}] #{@msg.strip}\n"
      else
        "#{formatted_time} #{HOST} #{APP}[#{$$}][#{formatted_severity}] #{@msg.class}: #{@msg.inspect}\n"
      end
    end
  end

  # Returns a String like object with the current name of the environment
  def self.env
    Env.new(ENV['NEZU_ENV']||'development')
  end

  def self.app
    configatron.app_name.classify
  end

  # Returns a String like object with the applications absolute root
  def self.root
    Root::APP_PATH
  end

  # turn errors into warnings if used in verbose mode (Nezu.try(true) { ... })
  # useful if you find it acceptable that something isn't
  # working
  def self.try(verbose=false, &block)
    yield
  rescue Exception => e
    Nezu.logger.warn("[Nezu Runner] Nezu.try failed") if verbose
    Nezu.logger.warn(e) if verbose
  end

  # spew log messages
  # just like any other ruby program
  # e.g. Nezu.logger.info('foobar')
  def self.logger
    if @@logger.nil?
      log_target = {
        'development' => STDOUT,
        'test' => nil,
        'production' => File.expand_path(File.join('log/', 'nezu.log'))
      }
      @@logger = Logger.new(log_target[Nezu.env])
      @@logger.formatter = Nezu::CustomLogFormatter.new
    end
    @@logger
  end
end

require 'debugger' unless Nezu.env.production?

