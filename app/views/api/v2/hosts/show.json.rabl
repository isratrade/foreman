object @host

attributes :name, :id, :ip, :environment_id, :environment_name, :last_report, :updated_at, :created_at, :mac,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :domain_id, :domain_name, :architecture_id, :architecture_name, :operatingsystem_id, :operatingsystem_name,
           :subnet_id, :sp_subnet_id, :ptable_id, :ptable_name, :medium_id, :medium_name, :build,
           :comment, :disk, :installed_at, :model_id, :hostgroup_id, :hostgroup_name, :hostgroup_name, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id, :compute_resource_name,
           :puppet_proxy_id, :certname, :image_id, :image_name

node do |host|
  { :puppetclasses => partial("api/v2/puppetclasses/base", :object => @host.all_puppetclasses) }
end

node do |host|
  { :smart_variables => partial("api/v2/smart_variables/base", :object => @host.smart_variables) }
end

node do |host|
  { :smart_class_parameters => partial("api/v2/smart_class_parameters/base", :object => @host.smart_class_parameters) }
end

node do |host|
  { :parameters => partial("api/v2/parameters/show", :object => @host.host_parameters) }
end