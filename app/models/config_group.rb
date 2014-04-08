class ConfigGroup < ActiveRecord::Base
  audited :allow_mass_assignment => true
  include Authorizable

  attr_accessible :name, :puppetclass_ids

  has_many :config_group_classes
  has_many :puppetclasses, :through => :config_group_classes
  has_many :host_config_groups
  has_many_hosts :through => :host_config_groups

  validates :name, :presence => true, :uniqueness => true

  scoped_search :on => :name, :complete_value => true
  default_scope lambda { order('config_groups.name') }

  def to_param
    "#{id}-#{name.parameterize}"
  end

  # the following methods are required for app/views/puppetclasses/_class_selection.html.erb
  alias_method :classes, :puppetclasses
  alias_method :individual_puppetclasses, :puppetclasses

  def available_puppetclasses
    Puppetclass.scoped
  end


end
