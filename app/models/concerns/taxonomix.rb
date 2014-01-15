module Taxonomix
  extend ActiveSupport::Concern

  included do
    taxonomy_join_table = "taxable_taxonomies"
    has_many taxonomy_join_table, :dependent => :destroy, :as => :taxable
    has_many :locations,     :through => taxonomy_join_table, :source => :taxonomy,
             :conditions => "taxonomies.type='Location'", :validate => false
    has_many :organizations, :through => taxonomy_join_table, :source => :taxonomy,
             :conditions => "taxonomies.type='Organization'", :validate => false
    after_initialize :set_current_taxonomy

    scoped_search :in => :locations, :on => :name, :rename => :location, :complete_value => true
    scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true
  end

  module ClassMethods
    def with_taxonomy_scope
      scope =  block_given? ? yield : where('1=1')
      scope = scope.where("#{self.table_name}.id in (#{inner_select(Location.current)}) #{user_conditions}") if SETTINGS[:locations_enabled] && Location.current && !Location.ignore?(self.to_s)
      scope = scope.where("#{self.table_name}.id in (#{inner_select(Organization.current)}) #{user_conditions}") if SETTINGS[:organizations_enabled] and Organization.current && !Organization.ignore?(self.to_s)
      scope.readonly(false)
    end

    def inner_select taxonomy
      taxonomy_ids = taxonomy.path_ids.join(',')
      "SELECT taxable_id from taxable_taxonomies WHERE taxable_type = '#{self.name}' AND taxonomy_id in (#{taxonomy_ids}) "
    end

    # I the case of users we want the taxonomy scope to get both the users of the taxonomy and admins.
    # This is done here and not in the user class because scopes cannot be chained with OR condition.
    def user_conditions
      sanitize_sql_for_conditions([" OR users.admin = ?", true]) if self == User
    end
  end

  def set_current_taxonomy
    if self.new_record? && self.errors.empty?
      self.locations     << Location.current     if add_current_location?
      self.organizations << Organization.current if add_current_organization?
    end
  end

  def add_current_organization?
    add_current_taxonomy?(:organization)
  end

  def add_current_location?
    add_current_taxonomy?(:location)
  end

  def add_current_taxonomy?(taxonomy)
    klass, association = case taxonomy
                           when :organization
                             [Organization, :organizations]
                           when :location
                             [Location, :locations]
                           else
                             raise ArgumentError, "unknown taxonomy #{taxonomy}"
                         end
    current_taxonomy = klass.current
    Taxonomy.enabled?(taxonomy) && current_taxonomy && !self.send(association).include?(current_taxonomy)
  end

  def used_location_ids
    used_taxonomy_ids(:location_id)
  end

  def used_organization_ids
    used_taxonomy_ids(:organization_id)
  end

  def used_or_selected_location_ids
    (location_ids + used_location_ids).uniq
  end

  def used_or_selected_organization_ids
    (organization_ids + used_organization_ids).uniq
  end

  protected

  def taxonmy_foreign_key_conditions
    if self.respond_to?(:taxonomy_foreign_conditions)
      taxonomy_foreign_conditions
    else
      { "#{self.class.base_class.to_s.tableize.singularize}_id".to_sym => id }
    end
  end

  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.where(taxonmy_foreign_key_conditions).pluck(type).uniq
  end

end
