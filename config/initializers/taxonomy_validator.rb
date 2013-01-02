class TaxonomyValidator < ActiveModel::Validator
  def validate(record)
#     tax = Taxonomy.find(record.taxonomy_id)
    Host.all.any? do |host|
     TaxableImporter.new(Host.first,record).matching?
     #   record.errors[:id] << 'doesnt match!!!'
     #   return
    end
    # end
  end
  #end
  # def validate_each(record, attribute, value)
  #   if ['Mr.', 'Mrs.', 'Dr.'].include?(value)
  #     record.errors[attribute] << 'must be Mr. Mrs. or Dr.'
  #   end
  # end


end