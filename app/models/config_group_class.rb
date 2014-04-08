class ConfigGroupClass < ActiveRecord::Base
  attr_accessible :config_group_id, :puppetclass_id

  belongs_to :puppetclass
  belongs_to :config_group

  validates :puppetclass_id, :presence => true
  validates :config_group_id, :presence => true,
                              :uniqueness => {:scope => :puppetclass_id}

end
