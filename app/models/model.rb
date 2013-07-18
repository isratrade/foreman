class Model < ActiveRecord::Base
  include Authorization

  has_many_hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  before_destroy EnsureNotUsedBy.new(:hosts)
<<<<<<< HEAD
  validates_uniqueness_of :name
  validates_presence_of :name
  default_scope :order => 'LOWER(models.name)'
=======
  validates :name, :uniqueness => true, :presence => true

  default_scope lambda { order('models.name') }
>>>>>>> d8547ba... fixes #2801 - remove LOWER() from default_scope that could cause Postgres error

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info

end
