module Nezu
  module Generators
    module Application
      class AppGenerator
        include Nezu::Generators

        def initialize(app_dir)
          @@destination_root = app_dir
          @@app_name =  File.basename(@@destination_root)
          @@name_space ||= Object.const_set(@@app_name.split(/_/).map(&:capitalize).join('').to_sym, Module.new)
          Nezu::Generators.const_set(:GENERATOR, self) unless Nezu::Generators.const_defined?(:GENERATOR)
        end

        def destination_root
          @@destination_root
        end

        def app_name
          @@app_name
        end

        def name_space
          @@name_space
        end

        def generate!
          raise Nezu::Generators::Application::AppGeneratorError, "\"#{destination_root}\" already exists" if Dir.exist?(destination_root)
          FileUtils.mkdir_p(destination_root)
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

