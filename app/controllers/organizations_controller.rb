class OrganizationsController < ApplicationController
  include Foreman::AutoCompleteSearch
  include Foreman::TaxonomiesController
end
