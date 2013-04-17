require 'rubygems'
require 'puppet_setting'
class Setting::Puppet < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    param_enc = Gem::Version.new(Facter.puppetversion.split('-').first) >= Gem::Version.new('2.6.5')
    ppsettings = PuppetSetting.new.get :storeconfigs
    Setting.transaction do
      [
        self.set('puppet_interval', "Puppet interval in minutes", 30 ),
        self.set('default_puppet_environment',"The Puppet environment Foreman will default to in case it can't auto detect it", "production"),
        self.set('modulepath',"The Puppet default module path in case Foreman can't auto detect it", "/etc/puppet/modules"),
        self.set('document_root', "Document root where puppetdoc files should be created", "#{Rails.root}/public/puppet/rdoc"),
        self.set('puppetrun', "Enables Puppetrun support", false),
        self.set('puppet_server', "Default Puppet server hostname", "puppet"),
        self.set('failed_report_email_notification', "Enable Email alerts per each failed Puppet report", false),
        self.set('using_storeconfigs', "Foreman is sharing its database with Puppet Store configs", ppsettings[:storeconfigs] == 'true'),
        self.set('Default_variables_Lookup_Path', "The Default path in which Foreman resolves host specific variables", ["fqdn", "hostgroup", "os", "domain"]),
        self.set('Enable_Smart_Variables_in_ENC', "Should the smart variables be exposed via the ENC yaml output?", true),
        self.set('Parametrized_Classes_in_ENC', "Should Foreman use the new format (2.6.5+) to answer Puppet in its ENC yaml output?", param_enc),
        self.set('enc_environment', "Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)", true),
        self.set('use_uuid_for_certificates', "Should Foreman use random UUID's for certificate signing instead of hostnames", false),
        self.set('update_environment_from_facts', "Should Foreman update a host's environment from its facts", false),
        self.set('remove_classes_not_in_environment',
                 "When Host and Hostgroup have different environments should all classes be included (regardless if they exists or not in the other environment)", false)
      ].compact.each { |s| self.create s.update(:category => "Setting::Puppet")}

      true

    end

  end

end
