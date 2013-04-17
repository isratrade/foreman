require 'puppet_setting'
class Setting::Provisioning < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    ppsettings = PuppetSetting.new.get :hostcert, :localcacert, :hostprivkey, :storeconfigs
    Setting.transaction do
      [
        self.set('root_pass', "Default encrypted root password on provisioned hosts (default is 123123)", "xybxa6JUkz63w"),
        self.set('safemode_render', "Enable safe mode config templates rendering (recommended)", true),
        self.set('ssl_certificate', "SSL Certificate path that Foreman would use to communicate with its proxies", ppsettings[:hostcert]),
        self.set('ssl_ca_file',  "SSL CA file that Foreman will use to communicate with its proxies", ppsettings[:localcacert]),
        self.set('ssl_priv_key', "SSL Private Key file that Foreman will use to communicate with its proxies", ppsettings[:hostprivkey]),
        self.set('manage_puppetca', "Should Foreman automate certificate signing upon provisioning new host", true),
        self.set('ignore_puppet_facts_for_provisioning', "Does not update ipaddress and MAC values from Puppet facts", false),
        self.set('query_local_nameservers', "Should Foreman query the locally configured name server or the SOA/NS authorities", false),
        self.set('remote_addr', "If Foreman is running behind Passenger or a remote loadbalancer, the ip should be set here", "127.0.0"),
        self.set('token_duration', "Time in minutes installation tokens should be valid for, 0 to disable", 0)
      ].each { |s| self.create s.update(:category => "Setting::Provisioning")}
    end

    true

  end

end
