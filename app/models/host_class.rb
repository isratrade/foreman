class HostClass < ActiveRecord::Base
  audited :associated_with => :host
  belongs_to :host
  belongs_to :puppetclass

  validates_uniqueness_of :puppetclass_id, :scope => :host_id

  def name
    "#{host} - #{puppetclass}"
  end
end
