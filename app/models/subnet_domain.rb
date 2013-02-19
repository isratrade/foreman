class SubnetDomain < ActiveRecord::Base
  belongs_to :domain
  belongs_to :subnet

  validates :subnet_id, :domain_id, :presence => true
  validates :domain_id, :uniqueness => {:scope => :subnet_id}

  def to_s
    "#{domain} : #{subnet}"
  end

end
