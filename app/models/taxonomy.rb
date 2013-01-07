class Taxonomy < ActiveRecord::Base
  audited
  has_associated_audits

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :type

  belongs_to :user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :config_templates, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ConfigTemplate'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'

  scoped_search :on => :name, :complete_value => true

  validate :check_for_orphans

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name =~ /[A-Z]/ ? name : name.capitalize
  end

  def self.locations_enabled
    SETTINGS[:locations_enabled]
  end

  def self.organizations_enabled
    SETTINGS[:organizations_enabled]
  end

  def self.no_taxonomy_scope
    as_taxonomy nil, nil do
      yield if block_given?
    end
  end

  def self.as_taxonomy org, location
    Organization.as_org org do
      Location.as_location location do
        yield if block_given?
      end
    end
  end

  def used_ids
    #initialize hash
    a = {:organization_ids => [],
         :location_ids => [],
         :hostgroup_ids => [],
         :environment_ids => [],
         :domain_ids => [],
         :config_template_ids => [],
         :medium_ids => [],
         :compute_resource_ids => [],
         :subnet_ids => [],
         :smart_proxy_ids => [],
         :user_ids => []
    }
    #loop through hosts for taxonomy only
    self.hosts.each do |host|
      a[:organization_ids] << host.organization_id
      a[:location_ids] << host.location_id
      a[:hostgroup_ids] << host.hostgroup_id
      a[:environment_ids] << host.environment_id
      a[:domain_ids] << host.domain_id
      a[:config_template_ids] << (host.operatingsystem_id.present? && host.configTemplate ?  host.configTemplate.id : nil)
      a[:medium_ids] << host.medium_id
      a[:compute_resource_ids] << host.compute_resource_id
      a[:subnet_ids]  << host.subnet_id
      a[:smart_proxy_ids] << host.smart_proxy_ids
      a[:user_ids] << (host.owner_type == 'User' ? host.owner_id : nil)
    end
    # remove nils in each array and make unqiue
    a[:organization_ids] = a[:organization_ids].uniq.compact
    a[:location_ids] = a[:location_ids].uniq.compact
    a[:hostgroup_ids] = a[:hostgroup_ids].uniq.compact
    a[:environment_ids] = a[:environment_ids].uniq.compact
    a[:domain_ids] = a[:domain_ids].uniq.compact
    a[:config_template_ids] = a[:config_template_ids].uniq.compact
    a[:medium_ids] = a[:medium_ids].uniq.compact
    a[:compute_resource_ids] =  a[:compute_resource_ids].uniq.compact
    a[:subnet_ids] = a[:subnet_ids].uniq.compact
    # flatten smart_proxy id's since array of arrays is returned
    a[:smart_proxy_ids] = a[:smart_proxy_ids].flatten.uniq.compact
    a[:user_ids] = a[:user_ids].uniq.compact
    return a
  end

  def selected_ids
    #initialize hash
    b = {:organization_ids => [],
         :location_ids => [],
         :hostgroup_ids => [],
         :environment_ids => [],
         :domain_ids => [],
         :config_template_ids => [],
         :medium_ids => [],
         :compute_resource_ids => [],
         :subnet_ids => [],
         :smart_proxy_ids => [],
         :user_ids => []
    }
    if self.is_a?(Location)
      b[:organization_ids] = organizations.pluck(:id)
    else
      b[:location_ids] = locations.pluck(:id)
    end
    b[:hostgroup_ids] = hostgroups.pluck(:id)
    b[:environment_ids] = environments.pluck(:id)
    b[:domain_ids] = domains.pluck(:id)
    b[:config_template_ids] = config_templates.pluck(:id)
    b[:medium_ids] = media.pluck(:id)
    b[:compute_resource_ids] =  compute_resources.pluck(:id)
    b[:subnet_ids] = subnets.pluck(:id)
    b[:smart_proxy_ids] = smart_proxies.pluck(:id)
    b[:user_ids] = users.pluck(:id)
    return b
  end

  def used_and_selected_ids
    a = used_ids
    b = selected_ids
    c = {:organization_ids => [],
         :location_ids => [],
         :hostgroup_ids => [],
         :environment_ids => [],
         :domain_ids => [],
         :config_template_ids => [],
         :medium_ids => [],
         :compute_resource_ids => [],
         :subnet_ids => [],
         :smart_proxy_ids => [],
         :user_ids => []
    }
    if self.is_a?(Location)
      c[:organization_ids] = a[:organization_ids] & b[:organization_ids]
    else
      c[:location_ids] = a[:location_ids] & b[:location_ids]
    end
    c[:environment_ids] = a[:environment_ids] & b[:environment_ids]
    c[:hostgroup_ids] = a[:hostgroup_ids] & b[:hostgroup_ids]
    c[:environment_ids] = a[:environment_ids] & b[:environment_ids]
    c[:domain_ids] = a[:domain_ids] & b[:domain_ids]
    c[:config_template_ids] = a[:config_template_ids] & b[:config_template_ids]
    c[:medium_ids] = a[:medium_ids] & b[:medium_ids]
    c[:compute_resource_ids] = a[:compute_resource_ids] & b[:compute_resource_ids]
    c[:subnet_ids] = a[:subnet_ids] & b[:subnet_ids]
    c[:smart_proxy_ids] = a[:smart_proxy_ids] & b[:smart_proxy_ids]
    c[:user_ids] = a[:user_ids] & b[:user_ids]
    return c
  end

  def need_to_be_selected_ids
    a = used_ids
    b = selected_ids
    d = {:organization_ids => [],
         :location_ids => [],
         :hostgroup_ids => [],
         :environment_ids => [],
         :domain_ids => [],
         :config_template_ids => [],
         :medium_ids => [],
         :compute_resource_ids => [],
         :subnet_ids => [],
         :smart_proxy_ids => [],
         :user_ids => []
    }
    if self.is_a?(Location)
      d[:organization_ids] = a[:organization_ids] - b[:organization_ids]
    else
      d[:location_ids] = a[:location_ids] - b[:location_ids]
    end
    d[:environment_ids] = a[:environment_ids] - b[:environment_ids]
    d[:hostgroup_ids] = a[:hostgroup_ids] - b[:hostgroup_ids]
    d[:environment_ids] = a[:environment_ids] - b[:environment_ids]
    d[:domain_ids] = a[:domain_ids] - b[:domain_ids]
    d[:config_template_ids] = a[:config_template_ids] - b[:config_template_ids]
    d[:medium_ids] = a[:medium_ids] - b[:medium_ids]
    d[:compute_resource_ids] = a[:compute_resource_ids] - b[:compute_resource_ids]
    d[:subnet_ids] = a[:subnet_ids] - b[:subnet_ids]
    d[:smart_proxy_ids] = a[:smart_proxy_ids] - b[:smart_proxy_ids]
    d[:user_ids] = a[:user_ids] - b[:user_ids] - User.only_admin.pluck(:id)
    return d
  end

  class Mismatch < StandardError ; end

  def check_for_orphans
    a = self.need_to_be_selected_ids
    found_orphan = false
    error_msg = "The following must be selected since they belong to hosts:\n\n"
    a.each do |key, array_values|
      unless array_values.length == 0
        class_name = key.to_s[0..-5].classify
        klass = class_name.constantize
        array_values.each do |id|
          row = klass.find_by_id(id)
          error_msg += "#{row.to_s} (#{class_name}) \n"
          found_orphan = true
        end
        errors.add(class_name.downcase.pluralize, "You cannot remove #{class_name.downcase.pluralize} that are used by hosts.")
      end
    end
    errors.add(:base, error_msg) if found_orphan
  end

end
