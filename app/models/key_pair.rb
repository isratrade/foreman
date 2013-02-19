class KeyPair < ActiveRecord::Base
  belongs_to :compute_resource
  validates :name, :secret, :compute_resource_id, :presence => true
  validates :compute_resource_id, :uniqueness => true
end
