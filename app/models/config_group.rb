class ConfigGroup < ActiveRecord::Base
  attr_accessible :name, :puppetclass_ids

  has_many :config_group_classes
  has_many :puppetclasses, :through => :config_group_classes
  has_many :host_config_groups
  has_many_hosts :through => :host_config_groups

  validates :name, :presence => true, :uniqueness => true

  scoped_search :on => :name, :complete_value => true
  default_scope lambda { order('config_groups.name') }

  # def to_param
  #   "#{id}-#{name.parameterize}"
  # end

  def environment
    nil
  end

  def all_puppetclasses
    puppetclasses
  end

end
