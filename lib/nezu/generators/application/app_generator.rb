module Nezu
  module Generators
    module Application
      class AppGenerator
        include Nezu::Generators

        def initialize(destination_root)
          app_name =  File.basename(destination_root)
          name_space = app_name.split(/_/).map(&:capitalize).join('').to_sym
          Object.const_set(name_space, Module.new) unless Object.const_defined?(name_space)
          @@config  = Nezu::Config::Template.new(:destination_root => destination_root,
                                     :app_name => app_name,
                                     :name_space => Object.const_get(name_space))
          Nezu::Generators.const_set(:GENERATOR, self) unless Nezu::Generators.const_defined?(:GENERATOR)
        end

        def config
          @@config
        end

        def generate!
          raise Nezu::Generators::Application::AppGeneratorError, "\"#{@@config.destination_root}\" already exists" if Dir.exist?(@@config.destination_root)
          FileUtils.mkdir_p(@@config.destination_root)
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

