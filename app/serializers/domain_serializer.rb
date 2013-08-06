class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :fullname, :created_at, :updated_at

end
