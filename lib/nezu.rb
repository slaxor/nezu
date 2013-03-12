require 'bundler'
Bundler.setup

require 'yaml'
require 'active_support/core_ext'
require 'active_record'
require 'configatron'

module Nezu
  GEM_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  class Env < String
    def method_missing(meth, params=nil)
      meth.to_s.sub(/\?$/, '') == self
    end

    def respond_to?(meth, params=nil)
      !!meth.to_s.match(/\?$/)
    end
  end

  class Root < String
    APP_PATH = self.new(File.expand_path(Dir.pwd))

    def join(*params)
      File.join(APP_PATH, params)
    end
  end

  class Error < Exception
    def new(e,msg)
      Nezu.logger.error(e.to_s)
      e.backtrace.each {|bt_line| Nezu.logger.error(bt_line)}
    end
  end

  class CustomLogFormatter
    SEVERITY_TO_COLOR_MAP = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'95;7;1', 'UNKNOWN'=>'37'}
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S."
    HOST = %x(hostname).chomp
    APP = File.basename(Dir.pwd)

    def call(severity, time, progname, msg)
      formatted_severity = sprintf("%-5s","#{severity}")
      formatted_time = time.strftime(TIME_FORMAT) << time.usec.to_s[0..2].rjust(3)
      color = SEVERITY_TO_COLOR_MAP[severity]
      if msg.kind_of?(Exception)
        "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{msg.to_s}\n" +
        msg.backtrace.map do |bt_line|
          "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{bt_line.strip}\n"
        end.join
      else
        "#{formatted_time} #{HOST} #{APP}[#{$$}][\033[#{color}m#{formatted_severity}\033[0m] #{msg.strip}\n"
      end
    end
  end


  def self.env
    Env.new(ENV['NEZU_ENV']||'development')
  end

  def self.root
    Root::PATH
  end

  def self.try(&block)
    yield
  rescue Exception => e
    Nezu.logger.warn("[Nezu Runner] Nezu.try failed")
    Nezu.logger.warn(e)
  end

  def self.load_config
    Nezu.try { configure_from_yaml('database.yml') }

    begin
      configure_from_yaml('amqp.yml')
    rescue
      Nezu.logger.fatal("[Nezu Runner] no amqp config please create one in config/amqp.yml") unless configatron.amqp.present?
      raise
    end

    if configatron.database.present?
      ActiveRecord::Base.establish_connection(configatron.database.to_hash)
      ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join('log/', 'database.log')))
    end
    require 'nezu/runtime'
    (Dir.glob(Nezu.root.join('app', '**', '*.rb')) + Dir.glob(Nezu.root.join('lib', '**', '*.rb'))).each do |file_name|
      require file_name
    end
    Nezu.logger.debug("[Nezu Runner] config loaded")
  end

  private

  def self.configure_from_yaml(yaml_file)
    Nezu.root.join('config', yaml_file)
    yaml = YAML.load_file(yaml_file)[Nezu.env]
    configatron.configure_from_hash(File.basename(yaml_file.sub(/.yml/, '')) => yaml)
  end

  @@logger=nil
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

