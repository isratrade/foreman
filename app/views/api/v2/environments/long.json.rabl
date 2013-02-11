object @environment

attributes :name, :id, :updated_at, :created_at, :has

child :hosts do
  extends "api/v1/hosts/show"
end

attribute :puppetclass_ids

child :config_templates do
  extends "api/v1/config_templates/show"
end

if SETTINGS[:locations_enabled]
  child :locations do
    extends "api/v2/taxonomies/short"
  end
end

if SETTINGS[:organizations_enabled]
  child :organizations do
    extends "api/v2/taxonomies/short"
  end
end
