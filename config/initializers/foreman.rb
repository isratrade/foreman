require 'foreman/access_control'
require 'foreman/access_permissions'
require 'foreman/default_data/loader'
require 'foreman/default_settings/loader'
require 'foreman/renderer'
require 'net'
require 'foreman/provision' if SETTINGS[:unattended]

module Foreman
  # generate a UUID
  def self.uuid
    UUIDTools::UUID.random_create.to_s
  end
end

# We load the default settings if they are not already present
Foreman::DefaultSettings::Loader.load

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
