collection @taxonomies, :root => root_node_name, :object_root => false

extends "api/v2/taxonomies/base"

node(:total) { @total }
node(:per_page) { @per_page }
node(:page) { @page }

node do
  { root_node_name => partial("api/v2/taxonomies/base", :object => @taxonomies) }
end

