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

  def get_obj_id
    obj_id   = :compute_resource_id if self.kind_of?(ComputeResource)
    obj_id   = :puppet_proxy_id if self.kind_of?(SmartProxy) && self.features.pluck(:name).include?("Puppet")
    obj_id   = :puppet_ca_proxy_id if self.kind_of?(SmartProxy) && self.features.pluck(:name).include?("Puppet CA")
    obj_id   = :owner_id if self.kind_of?(User)
    obj_id ||= "#{self.class.to_s.tableize.singularize}_id".to_sym
    obj_id
  end

  def used_location_ids
    return [] if new_record?
    obj_id = get_obj_id
    ids = Host.where(obj_id => self.id).pluck(:location_id).uniq if Host.new.respond_to?(obj_id)
    ids ||= []
    ids
  end

  def used_organization_ids
    return [] if new_record?
    obj_id = get_obj_id
    ids = Host.where(obj_id => self.id).pluck(:organization_id).uniq if Host.new.respond_to?(obj_id)
    ids ||= []
    ids
  end

  def used_or_selected_location_ids
    ids = (location_ids + used_location_ids).uniq
    ids
  end

  def used_or_selected_organization_ids
    ids = (organization_ids + used_organization_ids).uniq
    ids
  end

end
