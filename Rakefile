require 'bundler/gem_tasks'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'sdoc'
require 'debugger'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--fmt' << 'shtml'
  rdoc.template = 'direct'
end

namespace :version do
  namespace :bump do
    desc 'Increase the major number and set the others to zero'
    task :major do
      major, minor, patch = load_version
      store_version(major + 1, 0, 0)
    end

    desc 'Increase the minor number and set patch to zero'
    task :minor do
      major, minor, patch = load_version
      store_version(major, minor + 1, 0)
    end

    desc 'Increase the patch level'
    task :patch do
      major, minor, patch = load_version
      store_version(major, minor, patch + 1)
    end

    def load_version
      File.read(File.join(File.dirname(__FILE__), 'VERSION')).split('.').map(&:to_i)
    end

    def store_version(major, minor, patch)
      version = "#{major}.#{minor}.#{patch}"
      f= File.new(File.join(File.dirname(__FILE__), 'VERSION'), File::WRONLY)
      f.write(version)
      f.close
      puts "version is now #{version}"
    end
  end
end
