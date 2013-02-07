require 'fileutils'
require 'erb'
require 'nezu/generators/application/app_generator'

module Nezu
  module Generators

    TEMPLATE_PATHS = [File.join(Nezu::BASE_DIR, 'lib/nezu/generators/application/templates')] + ENV['NEZU_TEMPLATES'].to_s.split(':')

    FILE_SUFFIXES = %w(tt)

    def template_to(filename) # e.g. "config/amqp.yml"
      dirname = File.join(GENERATOR.destination_root, File.dirname(filename))
      source_file = find_template(filename)
      if source_file
        FileUtils.mkdir_p(dirname)

        if FILE_SUFFIXES.include?(source_file.split('.')[-1])
          e = ERB.new(File.read(source_file))
          File.open(File.join(GENERATOR.destination_root, filename.sub(/\.tt$/,'')), File::CREAT|File::TRUNC|File::WRONLY) do |f|
            f.write(e.result)
          end
        else
          FileUtils.cp(source_file, dirname)
        end
      end
    end

    private

    def find_template(filename)
      candidates = TEMPLATE_PATHS.map do |path|
        [File.join(path, filename)] +
        FILE_SUFFIXES.map do |suffix|
          File.join(path, filename) + '.' + suffix
        end
      end.flatten

      until candidates[-1].nil? || File.exist?(candidates[-1])
        candidates.pop
      end
      candidates[-1]
    end
  end
end

