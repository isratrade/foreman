module NestedAncestryCommon
  extend ActiveSupport::Concern

  included do
    before_save :set_label, :on => [:create, :update, :destroy]
    after_save :set_other_labels, :on => [:update, :destroy]

    scoped_search :on => :label, :complete_value => :true, :default_order => true
  end

  def get_label
    return name if ancestry.empty?
    ancestors.map { |a| a.name + '/' }.join + name
  end

  private

  def set_label
    self.label = get_label if (name_changed? || ancestry_changed? || label.blank?)
  end

  def set_other_labels
    if name_changed? || ancestry_changed?
      self.class.where('ancestry IS NOT NULL').each do |obj|
        if obj.path_ids.include?(self.id)
          obj.update_attributes(:label => obj.get_label)
        end
      end
    end
  end

end
