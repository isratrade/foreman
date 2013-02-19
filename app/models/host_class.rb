class HostClass < ActiveRecord::Base
  audited :associated_with => :host
  belongs_to :host
  belongs_to :puppetclass

  validates :host_id, :puppetclass_id, :presence => true

  def name
    "#{host} - #{puppetclass}"
  end
end
