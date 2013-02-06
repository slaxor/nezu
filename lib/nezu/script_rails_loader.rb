require 'pathname'

module Nezu
  class Runner
    APP_ROOT = Dir.pwd

    def self.run!
      return unless in_nezu_dir?
      exec RUBY, "#{APP_ROOT}/run.rb", *ARGV if in_nezu_dir?
    end

    def self.in_nezu_dir?
      File.exists?(File.join(Dir.pwd, 'Gemfile')) && File.read('Gemfile').match(/gem .*nezu/)
    end
  end
end
