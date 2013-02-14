require 'fileutils'
require 'erb'
require 'nezu/generators/application/app_generator'

module Nezu
  module Generators

    configatron.template_paths = [File.join(configatron.gem_base_dir 'lib/nezu/generators/application/templates')] + ENV['NEZU_TEMPLATES'].to_s.split(':')
    configatron.file_suffixes = %w(tt)

    def template_to(filename) # e.g. "config/amqp.yml"
      dirname = File.join(configatron.destination_root, File.dirname(filename))
      source_file = find_template(filename)
      if source_file
        FileUtils.mkdir_p(dirname)

        if configatron.file_suffixes.include?(source_file.split('.')[-1])
          e = ERB.new(File.read(source_file))
          File.open(File.join(configatron.destination_root, filename.sub(/\.tt$/,'')), File::CREAT|File::TRUNC|File::WRONLY) do |f|
            f.write(e.result(configatron.binding))
          end
        else
          FileUtils.cp(source_file, dirname)
        end
      end
    end

    private

    def find_template(filename)
      candidates = configatron.template_paths.map do |path|
        [File.join(path, filename)] +
        configatron.file_suffixes.map do |suffix|
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

