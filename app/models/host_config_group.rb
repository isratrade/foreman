class HostConfigGroup < ActiveRecord::Base
  attr_accessible :host_id, :config_group_id
  belongs_to :host, :polymorphic => true
  belongs_to :config_group

  validates :host_id, :uniqueness => { :scope => :config_group_id }

end
