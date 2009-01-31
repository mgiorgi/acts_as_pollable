require 'fileutils'
class ActsAsPollableGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # Migration template
      m.migration_template 'p_migration.rb', 'db/migrate', :migration_file_name => 'create_polls'
    end
  end
end
