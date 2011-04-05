# desc "Explaining what the task does"
# task :geo_regioning do
#   # Task goes here
# end
namespace :db do
  namespace :migrate do
    desc "Run migrations for the GeoRegioning Plugin"
    task :geo_regioning => :environment do
      ActiveRecord::Migrator.migrate("vendor/plugins/geo_regioning/lib/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
end