class Bookmark < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  attr_accessible :name, :controller, :query, :public

  validates :name, :uniqueness => true, :unless => Proc.new{|b| Bookmark.my_bookmarks.where(:name => b.name).empty?}
  validates :name, :controller, :query, :presence => true
  validates :controller, :format => { :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces." }

  default_scope lambda { order(:name) }
  before_validation :set_default_user

  scope :my_bookmarks, lambda {
    user = User.current
    return {} unless SETTINGS[:login] and !user.nil?

    user       = User.current
    conditions = sanitize_sql_for_conditions(["((bookmarks.public = ?) OR (bookmarks.owner_id = ? AND bookmarks.owner_type = 'User'))", true, user.id])
    {:conditions => conditions}
  }

  scope :controller, lambda { |*args| where("controller = ?", (args.first || '')) }

  def set_default_user
    self.owner ||= User.current
  end

  def to_param
    name
  end

end
