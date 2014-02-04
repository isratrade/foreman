class HostPuppetGroup < ActiveRecord::Base
  attr_accessible :host_id, :puppet_group_id
  belongs_to_host
  belongs_to :puppet_group

  validates :host_id, :uniqueness => { :scope => :puppet_group_id }

end
