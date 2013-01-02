class TaxableTaxonomy < ActiveRecord::Base

  belongs_to :taxonomy
  belongs_to :taxable, :polymorphic => true

  validates_uniqueness_of :taxonomy_id, :scope => [:taxable_id, :taxable_type]

  # before_destroy EnsureTaxonomyMatching.new

  # def mismatching_hosts
  #   taxonomy = Taxonomy.find_by_taxonomy_id(taxonomy_id)
  #   TaxableImporter.mismatches_for_taxonomy(taxonomy)
  # end

  # def matching?
  #   mismatching_hosts.length == 0
  # end

  # def ensure_no_orphans(record)
  #   #a = TaxableImporter.mismatches_for_taxonomy(self)
  #   #unless a.length == 0
  #     raise "this is from ensure_no_orphans"
  #  #end
  # end


end
