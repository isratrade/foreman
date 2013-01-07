class TaxableImporter

  def initialize(host, taxonomy)
    @host = host
    @taxonomy = taxonomy
  end


  def self.import_all
    Host.my_hosts.where('location_id > 0').each do |host|
      self.new(host, host.location).correct_mismatches
    end
    Host.my_hosts.where('organization_id > 0').each do |host|
      self.new(host, host.organization).correct_mismatches
    end
    return "Imported all taxable settings"
  end

  def self.mismatches_all
    a = Array.new
    Host.my_hosts.where('location_id > 0').each do |host|
      mismatches = self.new(host, host.location).mismatches
      if mismatches.length > 0
        a << {:host => host.name, :mismatches => mismatches}
      end
    end
    Host.my_hosts.where('organization_id > 0').each do |host|
      mismatches = self.new(host, host.organization).mismatches
      if mismatches.length > 0
        a << {:host => host.name, :mismatches => mismatches}
      end
    end
    return a
  end

  def self.mismatches_for_host(host)
    a = Array.new
    Host.my_hosts.where('location_id > 0').each do |host|
      mismatches = self.new(host, host.location).mismatches
      if mismatches.length > 0
        a << {:host => host.name, :mismatches => mismatches}
      end
    end
    Host.my_hosts.where('organization_id > 0').each do |host|
      mismatches = self.new(host, host.organization).mismatches
      if mismatches.length > 0
        a << {:host => host.name, :mismatches => mismatches}
      end
    end
    return a
  end

  def self.mismatches_for_taxonomy(obj)
    a = Array.new
    Host.where("#{obj.class.to_s.downcase}_id".to_sym => obj.id).each do |host|
      b = self.new(host, obj).mismatches
      if b.length > 0
        a << b
      end
    end
    return a.uniq
  end

  def matching?
    mismatches.length == 0
  end

  def correct_mismatches
    if mismatches.length > 0
      mismatches.each do |klass|
        field = (klass == 'User' ? "owner" : klass).tableize.singularize
        if klass == 'Location'
          @taxonomy.location_ids << @host.location_id
        elsif klass == 'Organization'
          @taxonomy.organization_ids << @host.organization_id
        else
          TaxableTaxonomy.create!(:taxonomy_id => @taxonomy.id,
                                  :taxable_id => @host.send("#{field}_id"),
                                  :taxable_type => klass
                                )
        end
      end
    end
  end

  def missing_ids
    missing_ids = Array.new
    if @taxonomy.is_a?(Location)
      if @host.organization_id.present? && !@taxonomy.organizations.pluck(:id).include?(@host.organization_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Organization", :taxable_id => @host.organization_id}
      end
    else
      if @host.organization_id.present? && !@taxonomy.locations.pluck(:id).include?(@host.location_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Location", :taxable_id => @host.location_id}
      end
    end
    if @host.hostgroup_id.present? && !@taxonomy.hostgroups.pluck(:id).include?(@host.hostgroup_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Hostgroup", :taxable_id => @host.hostgroup_id}
    end
    if @host.environment_id.present? && !@taxonomy.environments.pluck(:id).include?(@host.environment_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Environment", :taxable_id => @host.environment_id}
    end
    if @host.operatingsystem_id.present? && @host.configTemplate && !@taxonomy.config_templates.pluck(:id).include?(@host.configTemplate.id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "ConfigTemplate", :taxable_id => @host.configTemplate.id}
    end
    if @host.medium_id.present? && !@taxonomy.media.pluck(:id).include?(@host.medium_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Medium", :taxable_id => @host.medium_id}
    end
    if @host.compute_resource_id.present? && !@taxonomy.compute_resources.pluck(:id).include?(@host.compute_resource_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "ComputeResource", :taxable_id => @host.compute_resource_id}
    end
    if @host.subnet_id.present? && !@taxonomy.subnets.pluck(:id).include?(@host.subnet_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Subnet", :taxable_id => @host.subnet_id}
    end
    if @host.domain_id.present? && !@taxonomy.domains.pluck(:id).include?(@host.domain_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "Domain", :taxable_id => @host.domain_id}
    end
    if @host.smart_proxies.count > 0
      @host.smart_proxies.each do |smart_proxy|
        if smart_proxy.try(:id) && !@taxonomy.smart_proxies.pluck(:id).include?(smart_proxy.id)
          missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "SmartProxy", :taxable_id => smart_proxy.id}
        end
      end
    end
    if @host.owner_id.present? && @host.owner_type == "User" && !User.find(@host.owner_id).admin && !@taxonomy.users.pluck(:id).include?(@host.owner_id)
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => "User", :taxable_id => @host.owner_id}
    end
    return missing_ids
  end

  def mismatches
    mismatches = Array.new
    if @taxonomy.is_a?(Location)
      if @host.organization_id.present? && !@taxonomy.organizations.pluck(:id).include?(@host.organization_id)
        mismatches << {:mismatch_on => "Organization", :value => @host.organization.name}
      end
    else
      if @host.organization_id.present? && !@taxonomy.locations.pluck(:id).include?(@host.location_id)
        mismatches << {:mismatch_on => "Location", :value => @host.location.name}
      end
    end
    if @host.hostgroup_id.present? && !@taxonomy.hostgroups.pluck(:id).include?(@host.hostgroup_id)
      mismatches << {:mismatch_on => "Hostgroup", :value => @host.hostgroup.name}
    end
    if @host.environment_id.present? && !@taxonomy.environments.pluck(:id).include?(@host.environment_id)
      mismatches << {:mismatch_on => "Environment", :value => @host.environment.name}
    end
    if @host.operatingsystem_id.present? && @host.configTemplate && !@taxonomy.config_templates.pluck(:id).include?(@host.configTemplate.id)
      mismatches << {:mismatch_on => "ConfigTemplate", :value => @host.configTemplate.name}
    end
    if @host.medium_id.present? && !@taxonomy.media.pluck(:id).include?(@host.medium_id)
      mismatches << {:mismatch_on => "Medium", :value => @host.compute_resource.name}
    end
    if @host.compute_resource_id.present? && !@taxonomy.compute_resources.pluck(:id).include?(@host.compute_resource_id)
      mismatches << {:mismatch_on => "ComputeResource", :value => @host.compute_resource.name}
    end
    if @host.subnet_id.present? && !@taxonomy.subnets.pluck(:id).include?(@host.subnet_id)
      mismatches << {:mismatch_on => "Subnet", :value => @host.subnet.name}
    end
    if @host.domain_id.present? && !@taxonomy.domains.pluck(:id).include?(@host.domain_id)
      mismatches << {:mismatch_on => "Domain", :value => @host.domain.name}
    end
    if @host.smart_proxies.count > 0
      @host.smart_proxies.each do |smart_proxy|
        if smart_proxy.try(:id) && !@taxonomy.smart_proxies.pluck(:id).include?(smart_proxy.id)
          mismatches << {:mismatch_on => "SmartProxy", :value => @host.smart_proxy.name}
        end
      end
    end
    if @host.owner_id.present? && @host.owner_type == "User" && !User.find(@host.owner_id).admin && !@taxonomy.users.pluck(:id).include?(@host.owner_id)
      mismatches << {:mismatch_on => "User", :value => @host.owner.name}
    end
    return mismatches
  end

  def matches
    matches = Array.new
    if @taxonomy.is_a?(Location)
      if @host.organization_id.present? && @taxonomy.organizations.pluck(:id).include?(@host.organization_id)
        matches << "Organization"
      end
    else
      if @host.organization_id.present? && @taxonomy.locations.pluck(:id).include?(@host.location_id)
        matches << "Location"
      end
    end
    if @host.hostgroup_id.present? && @taxonomy.hostgroups.pluck(:id).include?(@host.hostgroup_id)
      matches << "Hostgroup"
    end
    if @host.environment_id.present? && @taxonomy.environments.pluck(:id).include?(@host.environment_id)
      matches << "Environment"
    end
    if @host.configTemplate.present? && @taxonomy.config_templates.pluck(:id).include?(@host.configTemplate.id)
      matches << "ConfigTemplate"
    end
    if @host.medium_id.present? && @taxonomy.media.pluck(:id).include?(@host.medium_id)
      matches << "Medium"
    end
    if @host.compute_resource_id.present? && @taxonomy.compute_resources.pluck(:id).include?(@host.compute_resource_id)
      matches << "ComputeResource"
    end
    if @host.subnet_id.present? && @taxonomy.subnets.pluck(:id).include?(@host.subnet_id)
      matches << "Subnet"
    end
    if @host.domain_id.present? && @taxonomy.domains.pluck(:id).include?(@host.domain_id)
      matches << "Domain"
    end
    if @taxonomy.smart_proxies.pluck(:id).include?(smart_proxy_id)
      mismatches << "SmartProxy"
    end
    if @host.owner_id.present? && @host.owner_type == "User" && (User.find(@host.owner_id).admin || @taxonomy.users.pluck(:id).include?(@host.owner_id) )
      matches << "User"
    end
    return matches
  end


end
