require 'facter'
class Setting::General < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    Setting.transaction do
      domain = Facter.domain
      [
        self.set('administrator', "The default administrator email address", "root@#{domain}"),
        self.set('foreman_url',   "The hostname where your Foreman instance is reachable", "foreman.#{domain}"),
        self.set('email_reply_address', "The email reply address for emails that Foreman is sending", "Foreman-noreply@#{domain}"),
        self.set('entries_per_page', "The amount of records shown per page in Foreman", 20),
        self.set('authorize_login_delegation',"Authorize login delegation with REMOTE_USER environment variable",false),
        self.set('authorize_login_delegation_api',"Authorize login delegation with REMOTE_USER environment variable for API calls too",false),
        self.set('idle_timeout',"Log out idle users after a certain number of minutes",60),
        self.set('max_trend',"Max days for Trends graphs",30),
        self.set('use_gravatar',"Should Foreman use gravatar to display user icons",true)
      ].each { |s| self.create s.update(:category => "Setting::General")}
    end

    true

  end

end
