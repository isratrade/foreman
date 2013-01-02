class Taxonomy < ActiveRecord::Base
  audited
  has_associated_audits
#  include ActiveModel::Validations
#  validates_with TaxonomyValidator

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :type

  belongs_to :user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User', :after_remove => :ensure_no_orphans
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy', :after_remove => :ensure_no_orphans
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource', :after_remove => :ensure_no_orphans
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium', :after_remove => :ensure_no_orphans
  has_many :config_templates, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ConfigTemplate', :after_remove => :ensure_no_orphans
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain', :after_remove => :ensure_no_orphans
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup', :after_remove => :ensure_no_orphans
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment', :after_remove => :ensure_no_orphans
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet', :after_remove => :ensure_no_orphans

  scoped_search :on => :name, :complete_value => true

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

  class Mismatch < StandardError ; end

  def ensure_no_orphans(record)
    a = TaxableImporter.mismatches_for_taxonomy(self)
    error_msg = ""
    unless a.length == 0
      a.each do |line|
        line.each do |err|
          error_msg += "Host #{err[:host].to_s} uses #{err[:mismatch_on].to_s} #{err[:value].to_s}\n"
        end
      end
      raise Mismatch, error_msg
    end
  end

end
