object @operatingsystem

extends "api/v2/operatingsystems/main"

attributes :name, :major, :minor

child :media, :object_root => false do
  # change this to show partial "api/v2/media/base.json.rabl" when ready
  attributes :id, :name
end

child :architectures, :object_root => false do
  # change this to show partial "api/v2/architectures/base.json.rabl" when ready
  attributes :id, :name
end

child :ptables, :object_root => false do
  # change this to show partial "api/v2/ptables/base.json.rabl" when ready
  attributes :id, :name
end

child :config_templates, :object_root => false do
  # change this to show partial "api/v2/config_templates/base.json.rabl" when ready
  attributes :id, :name
end

child :os_default_templates, :object_root => false do
  # change this to show partial "api/v2/os_default_templates/base.json.rabl" when ready
  attributes :id, :config_template_id, :template_kind_id
end
