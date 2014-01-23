class TaxableTaxonomy < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :taxable, :polymorphic => true

  validates :taxonomy_id, :uniqueness => {:scope => [:taxable_id, :taxable_type]}
  after_save :ensure_uniqueness_on_parent

  scope :without, lambda{ |types|
    if types.empty?
      {}
    else
      where(["taxable_taxonomies.taxable_type NOT IN (?)",types])
    end
  }

  def ancestor_ids
    Taxonomy.find(taxonomy_id).ancestor_ids
  end

  # in case the controller callback avoid_duplicate_taxable doesn't work
  def ensure_uniqueness_on_parent
    if TaxableTaxonomy.where(:taxonomy_id => ancestor_ids, :taxable_id => taxable_id, :taxable_type => taxable_type).any?
      self.destroy
    end
  end

end
