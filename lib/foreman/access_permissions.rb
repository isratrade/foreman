require 'foreman/access_control'

# Permissions
Foreman::AccessControl.map do |map|

  #key = security block name, value => controller name
  crud_controllers = {:architectures => :architectures,
                     :authentication_providers => :auth_source_ldaps,
                     :bookmarks => :bookmarks,
                     :compute_resources => :compute_resources,
                     :compute_resources_vms => :compute_resources_vms,
                     :config_templates => :config_templates,
                     :domains => :domains,
                     :smart_variables => :lookup_keys,
                     :environments => :environments,
                     :global_variables => :common_parameters,
                     :hostgroups => :hostgroups,
                     :hosts => :hosts,
                     :media => :media,
                     :models => :models,
                     :operatingsystems => :operatingsystems,
                     :partition_tables => :ptables,
                     :puppetclasses => :puppetclasses,
                     :smart_proxies => :smart_proxies,
                     :subnets => :subnets,
                     :trends => :trends,
                     :usergroups => :usergroups,
                     :users => :users
                      }

  crud_controllers.each do |security_block_name, controller_name|
    map.security_block(security_block_name.to_sym) do |map|
      map.permission "view_#{security_block_name}".to_sym,
                       controller_name.to_sym => [:index, :show], "api/v1/#{controller_name}".to_sym => [:index, :show]
      map.permission "create_#{security_block_name}".to_sym,
                       controller_name.to_sym => [:new, :create], "api/v1/#{controller_name}".to_sym => [:create]
      map.permission "edit_#{security_block_name}".to_sym,
                       controller_name.to_sym => [:edit, :update], "api/v1/#{controller_name}".to_sym=> [:update]
      map.permission "destroy_#{security_block_name}".to_sym,
                       controller_name.to_sym => [:destroy], "api/v1/#{controller_name}".to_sym => [:destroy]
    end
  end


  map.security_block :compute_resources_vms do |map|
    map.permission :power_compute_resources_vms,
                      :compute_resources_vms => [:power],
                      :"api/v1/compute_resources_vms" => [:power]
  end

  map.security_block :environments do |map|
    map.permission :import_environments,
                      :environments => [:import_environments, :obsolete_and_new],
                      :"api/v1/environments" => [:import_environments, :obsolete_and_new]
  end

  map.security_block :hosts do |map|
    map.permission :view_hosts,
                      :hosts => [:errors, :active, :out_of_sync, :disabled],
                      :"api/v1/hosts" => [:errors, :active, :out_of_sync, :disabled],
                      :dashboard => [:OutOfSync, :errors, :active],
                      :"api/v1/dashboard" => [:OutOfSync, :errors, :active]

    map.permission :create_hosts,
                      :hosts => [:clone],
                      :"api/v1/hosts" => [:clone]

    map.permission :edit_hosts,
                      :hosts => [:multiple_actions, :reset_multiple,
                                      :select_multiple_hostgroup, :select_multiple_environment, :submit_multiple_disable,
                                      :multiple_parameters, :multiple_disable, :multiple_enable, :update_multiple_environment,
                                      :update_multiple_hostgroup, :update_multiple_parameters, :toggle_manage],
                      :"api/v1/hosts" => [:multiple_actions, :reset_multiple,
                                      :select_multiple_hostgroup, :select_multiple_environment, :submit_multiple_disable,
                                      :multiple_parameters, :multiple_disable, :multiple_enable, :update_multiple_environment,
                                      :update_multiple_hostgroup, :update_multiple_parameters, :toggle_manage]

    map.permission :destroy_hosts,
                      :hosts => [:multiple_actions, :reset_multiple, :multiple_destroy, :submit_multiple_destroy],
                      :"api/v1/hosts" => [:multiple_actions, :reset_multiple, :multiple_destroy, :submit_multiple_destroy]

    map.permission :build_hosts,
                      :hosts => [:setBuild, :cancelBuild, :submit_multiple_build],
                      :"api/v1/hosts" => [:setBuild, :cancelBuild, :submit_multiple_build]

    map.permission :power_hosts,
                      :hosts => [:power],
                      :"api/v1/hosts" => [:power]

    map.permission :console_hosts,
                      :hosts => [:console],
                      :"api/v1/hosts" => [:console]
  end

  map.security_block :host_editing do |map|
    map.permission :edit_classes,
                      :host_editing => [:edit_classes],
                      :"api/v1/host_editing" => [:edit_classes]
    map.permission :create_params,
                      :host_editing => [:create_params],
                      :"api/v1/host_editing" => [:create_params]
    map.permission :edit_params,
                      :host_editing => [:edit_params],
                      :"api/v1/host_editing" => [:edit_params]
    map.permission :destroy_params,
                      :host_editing => [:destroy_params],
                      :"api/v1/host_editing" => [:destroy_params]
  end

  map.security_block :puppetclasses do |map|
    map.permission :import_puppetclasses,
                      :puppetclasses => [:import_environments],
                      :"api/v1/puppetclasses" => [:import_environments]
  end

  map.security_block :smart_proxies_autosign do |map|
    map.permission :view_smart_proxies_autosign,
                      :smart_proxies_autosign => [:index, :show],
                      :"api/v1/smart_proxies_autosign" => [:index, :show]
    map.permission :create_smart_proxies_autosign,
                      :smart_proxies_autosign => [:new, :create],
                      :"api/v1/smart_proxies_autosign" => [:create]
    map.permission :destroy_smart_proxies_autosign,
                      :smart_proxies_autosign => [:destroy],
                      :"api/v1/smart_proxies_autosign" => [:destroy]
  end

  map.security_block :smart_proxies_puppetca do |map|
    map.permission :view_smart_proxies_puppetca,
                      :smart_proxies_puppetca => [:index],
                      :"api/v1/smart_proxies_puppetca" => [:index]
    map.permission :edit_smart_proxies_puppetca,
                      :smart_proxies_puppetca => [:update],
                      :"api/v1/smart_proxies_puppetca" => [:update]
    map.permission :destroy_smart_proxies_puppetca,
                      :smart_proxies_puppetca => [:destroy],
                      :"api/v1/smart_proxies_puppetca" => [:destroy]
  end

  map.security_block :settings_menu do |map|
    map.permission :access_settings,
                      :home => [:settings],
                      :"api/v1/home" => [:settings]
  end

  map.security_block :dashboard do |map|
    map.permission :access_dashboard,
                      :dashboard => [:index],
                      :"api/v1/dashboard" => [:index]
  end

  map.security_block :reports do |map|
    map.permission :view_reports,
                      :reports => [:index, :show],
                      :"api/v1/reports" => [:index, :show]
    map.permission :destroy_reports,
                      :reports => [:destroy],
                      :"api/v1/reports" => [:destroy]
  end

  map.security_block :facts do |map|
    map.permission :view_facts,
                      :fact_values => [:index, :show],
                      :"api/v1/fact_values" => [:index, :show]
  end

  map.security_block :audit_logs do |map|
    map.permission :view_audit_logs,
                      :audits => [:index, :show],
                      :"api/v1/audits" => [:index, :show]
  end
  map.security_block :statistics do |map|
    map.permission :view_statistics,
                      :statistics => [:index, :show],
                      :"api/v1/statistics" => [:index, :show]
  end

end
