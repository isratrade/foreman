class LocationsController < ApplicationController
  include Foreman::AutoCompleteSearch
  include Foreman::TaxonomiesController
end
