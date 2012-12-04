module Api
  module V1
    class ParametersController < V1::BaseController
      before_filter :find_resource

      api :GET, "/references/:id/parameters/", "List all parameters."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @host_parameters = HostParameter.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/references/:id/parameters/:id/", "Show a parameter."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/references/:id/parameters/", "Create a parameter"
      param :parameter, Hash, :required => true do
        param :name, String, :required => true
        param :value, String, :required => true
      end

      def create
        @parameter = HostParameter.new(params[:parameter])
        process_response @parameter.save
      end

      api :PUT, "/references/:id/parameters/:id/", "Update a parameter"
      param :id, :identifier, :required => true
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def update
        process_response @parameter.update_attributes(params[:parameter])
      end

      api :DELETE, "/references/:id/parameters/:id/", "Delete a parameter"
      param :id, :identifier, :required => true

      def destroy
        process_response @parameter.destroy
      end

    end
  end
end
