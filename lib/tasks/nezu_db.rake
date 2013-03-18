#require 'nezu/runner'
require 'active_support/core_ext/object/inclusion'
require 'active_record'
require 'debugger'

namespace :nezu do
  db_namespace = namespace :db do
    task :load_config do
      Nezu.logger.level = Logger::INFO
      Nezu::Runtime.load_config
    end

    desc 'Create all the local databases defined in config/database.yml'
    task :create => [:load_config] do
        databases = YAML.load_file(File.join(Nezu.root.join('config', 'database.yml'))).map {|k,v| v }.uniq
        databases.each do |db|
          print "creating #{db['database']}..."
          ActiveRecord::Base.establish_connection(db.merge({'database' => nil}))
          ActiveRecord::Base.connection.create_database(db['database']) rescue (puts 'ERROR'; next)
          puts 'done'
        end
    end

    desc "Migrate the database (options: VERSION=x, VERBOSE=false)."
    task :migrate => [:load_config] do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
        ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
      end
      db_namespace["schema:dump"].invoke
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task :rollback => [:load_config] do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      db_namespace['schema:dump'].invoke
    end

    namespace :migrate do
      # desc 'Resets your database using your migrations for the current environment'
      #task :reset => ['db:drop', 'db:create', 'db:migrate']

      desc 'Runs the "up" for a given migration VERSION.'
      task :up => [:load_config] do
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
        raise 'VERSION is required' unless version
        ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
        db_namespace['dump'].invoke
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down => [:load_config] do
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
        raise 'VERSION is required' unless version
        ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_paths, version)
        db_namespace['_dump'].invoke
      end

      # desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
      task :redo => [:load_config] do
        if ENV['VERSION']
          db_namespace['migrate:down'].invoke
          db_namespace['migrate:up'].invoke
        else
          db_namespace['rollback'].invoke
          db_namespace['migrate'].invoke
        end
      end
    end

    namespace :schema do
      desc 'Create a db/schema.rb file'
      task :dump => [:load_config] do
        require 'active_record/schema_dumper'
        filename = ENV['SCHEMA'] || "#{Nezu.root}/db/schema.rb"
        File.open(filename, "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc 'Create a db from schema.rb file'
      task :load => [:load_config] do
        #require 'active_record/schema_dumper'
        #filename = ENV['SCHEMA'] || "#{Nezu.root}/db/schema.rb"
        #File.open(filename, "w:utf-8") do |file|
          #ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        #end
      end
    end
  end
end


