class HostgroupClass < ActiveRecord::Base
  audited :associated_with => :hostgroup
  belongs_to :hostgroup
  belongs_to :puppetclass

  attr_accessible :hostgroup_id, :hostgroup, :puppetclass_id, :puppetclass
  validates :hostgroup_id, :puppetclass_id, :presence => true

  def name
    "#{hostgroup} - #{puppetclass}"
  end

end
