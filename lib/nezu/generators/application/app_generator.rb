module Nezu
  module Generators
    module Application
      class AppGenerator
        include Nezu::Generators

        def initialize(destination_root)
          configatron.destination_root = destination_root
          configatron.app_name =  File.basename(destination_root)
          configatron.name_space = configatron.app_name.split(/_/).map(&:capitalize).join('').to_sym
          Object.const_set(configatron.name_space, Module.new) unless Object.const_defined?(configatron.name_space)
        end

        def generate!
          raise Nezu::Generators::Application::AppGeneratorError, "\"#{configatron.destination_root}\" already exists" if Dir.exist?(configatron.destination_root)
          FileUtils.mkdir_p(configatron.destination_root)
          generate_files_from_manifest!
        end

        def generate_files_from_manifest! # TODO rewrite so a MANIFEST isn´t needed
          File.readlines(File.join(File.dirname(__FILE__), 'MANIFEST')).each do |filename|
            template_to(filename.chomp)
          end
        end
      end
      class AppGeneratorError < Exception
      end
    end
  end
end

