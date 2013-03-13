#require 'nezu/runner'
require 'active_support/core_ext/object/inclusion'
require 'active_record'
require 'debugger'

#def load_config
  #yaml = YAML.load_file(File.join(Nezu.root.join('config', 'database.yml')))
  #configatron.databases.configure_from_hash(yaml)
#end

def connect_to(env, without_db=false)
  config = configatron.databases.send(env).to_hash
  config.delete(:database) if without_db
  @connection = ActiveRecord::Base.establish_connection(config)
end

namespace :nezu do
  db_namespace = namespace :db do
    task :load_config do
      yaml = YAML.load_file(File.join(Nezu.root.join('config', 'database.yml')))
      configatron.databases.configure_from_hash(yaml)
    end

    desc 'Create all the local databases defined in config/database.yml'
    task :create do
      begin
        load_config
        configatron.databases.to_hash.each do |k,v|
          print "creating #{k}`s db (#{v}) ... "
          connect_to(k, true)
          ActiveRecord::Base.connection.create_database(v[:database])
          puts 'done'
        end
      rescue Mysql2::Error => e
        puts "not done (#{e.to_s})"
      end
    end

    task :migrate => [:load_config] do
      connect_to(Nezu.env)
      if ENV['VERSION']
        db_namespace['migrate:down'].invoke
        db_namespace['migrate:up'].invoke
      else
        ActiveRecord::Migrator.migrate(Nezu.root.join('db', 'migrate')) do |migration|
          migration.migrate(:up)
        end
      end
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task :rollback => [:environment, :load_config] do
      connect_to(Nezu.env)
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      db_namespace['schema:dump'].invoke
    end

    namespace :migrate do
      # desc 'Resets your database using your migrations for the current environment'
      #task :reset => ['db:drop', 'db:create', 'db:migrate']

      desc 'Runs the "up" for a given migration VERSION.'
      task :up => [:environment, :load_config] do
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
        raise 'VERSION is required' unless version
        ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
        db_namespace['dump'].invoke
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down => [:environment, :load_config] do
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
        raise 'VERSION is required' unless version
        ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_paths, version)
        db_namespace['_dump'].invoke
      end

      # desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
      task :redo => [:environment, :load_config] do
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
      task :dump => [:environment, :load_config] do
        require 'active_record/schema_dumper'
        connect_to(Nezu.env)
        filename = ENV['SCHEMA'] || "#{Nezu.root}/db/schema.rb"
        File.open(filename, "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc 'Create a db from schema.rb file'
      task :load => [:load_config] do
        #require 'active_record/schema_dumper'
        connect_to(Nezu.env)
        #filename = ENV['SCHEMA'] || "#{Nezu.root}/db/schema.rb"
        #File.open(filename, "w:utf-8") do |file|
          #ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        #end
      end
    end
  end
end


