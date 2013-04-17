require 'foreman'

# We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
begin
  Setting.first
rescue
else
  # We load the default settings if they are not already present
  # In Development, we need to load the classes explicitly
  Setting.descendants.each do |setting|
    setting.load_defaults
  end
end

# We load the default settings for the roles if they are not already present
Foreman::DefaultData::Loader.load(false)

# clear our users topbar cache
begin
  User.unscoped.pluck(:id).each do |id|
    Rails.cache.delete("views/tabs_and_title_records-#{id}")
  end
rescue => e
  Rails.logger.warn e
end
