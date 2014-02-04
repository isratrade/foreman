class PuppetGroup < ActiveRecord::Base
  attr_accessible :name

  has_many :puppet_group_classes
  has_many :puppetes, :through => :puppet_group_classes
  has_many :host_puppet_groups
  has_many_hosts :through => :host_puppet_groups

  validates :name, :presence => true, :uniqueness => true

end
