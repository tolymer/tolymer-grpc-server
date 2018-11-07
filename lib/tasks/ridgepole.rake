namespace :ridgepole do
  desc 'Apply schema definition'
  task :apply do
    sh 'ridgepole', '--config', 'config/database.yml', '--env', ENV.fetch('RAILS_ENV', 'development'), '--apply', '--file', 'db/Schemafile.rb'

    unless Rails.env.production?
      Rake::Task['db:schema:dump'].invoke
      Rake::Task['db:test:prepare'].invoke
      Rails.root.join('db/schema.rb').delete
    end
  end

  desc 'Show difference between schema definition and actual schema'
  task :'dry-run' do
    sh 'ridgepole', '--config', 'config/database.yml', '--env', ENV.fetch('RAILS_ENV', 'development'), '--apply', '--dry-run', '--file', 'db/Schemafile.rb'
  end
end
