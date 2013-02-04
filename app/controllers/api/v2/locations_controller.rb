module Api
  module V2
    class LocationsController < V2::BaseController

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/locations", "List of Locations"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if params[:organization_id].present?
          @organization = Organization.find(params[:organization_id])
          @locations = @organization.locations.paginate(paginate_options)
        else
          @locations = Location.paginate(paginate_options)
        end
      end

      api :GET, "/locations/:id/", "Show a location."
      param :id, String, :required => true

      def show
      end

      api :POST, "/locations/", "Create a location."
      param :location, Hash, :required => true do
        param :name, String, :required => true
      end

      def create
        @location = Location.new(params[:location])
        process_response @location.save
      end

      def update
        process_response @location.update_attributes(params[:location])
      end

      api :DELETE, "/locations/:id/", "Delete a Location."
      param :id, :identifier, :required => true

      def destroy
        process_response @location.destroy
      end

    end
  end
end