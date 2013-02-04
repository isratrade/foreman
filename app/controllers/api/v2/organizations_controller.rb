module Api
  module V2
    class OrganizationsController < V2::BaseController

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/Organizations", "List of Organizations"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if params[:location_id].present?
          @location = Location.find(params[:location_id])
          @organizations = @location.organizations.search_for(*search_options).paginate(paginate_options)
        else
          @organizations = Organization.search_for(*search_options).paginate(paginate_options)
        end
      end

      api :GET, "/Organizations/:id/", "Show an Organization."
      param :id, String, :required => true

      def show
      end

      api :POST, "/Organizations/", "Create an Organization."
      param :organization, Hash, :required => true do
        param :name, String, :required => true
      end

      def create
        @organization = Organization.new(params[:organization])
        process_response @organization.save
      end

      def update
        process_response @organization.update_attributes(params[:organization])
      end

      api :DELETE, "/Organizations/:id/", "Delete an Organization."
      param :id, :identifier, :required => true

      def destroy
        process_response @organization.destroy
      end

    end
  end
end