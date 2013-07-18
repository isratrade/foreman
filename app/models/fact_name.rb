class FactName < ActiveRecord::Base

  has_many :fact_values, :dependent => :destroy
  has_many :user_facts, :dependent => :destroy
  has_many :users, :through => :user_facts
  has_many_hosts :through => :fact_values

  scope :no_timestamp_fact, :conditions => ["fact_names.name <> ?",:_timestamp]
  scope :timestamp_facts,   :conditions => ["fact_names.name = ?", :_timestamp]

<<<<<<< HEAD
  default_scope :order => 'LOWER(fact_names.name)'
=======
  default_scope lambda { order('fact_names.name') }
>>>>>>> d8547ba... fixes #2801 - remove LOWER() from default_scope that could cause Postgres error

  validate :name, :uniqueness => true

  def to_param
    name
  end

end
