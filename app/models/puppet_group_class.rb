class PuppetGroup < ActiveRecord::Base
  attr_accessible :puppet_group_id, :puppet_id

  belongs_to :puppetclass
  belongs_to :puppet_group

  validates :puppet_id, :uniqueness => { :scope => :puppet_group_id }
end
