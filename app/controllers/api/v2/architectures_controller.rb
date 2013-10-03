module Api
  module V2
    class ArchitecturesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_optional_nested_object

      api :GET, "/architectures", "List all architectures."
      api :GET, "/operatingsystems/:operatingsystem_id/architectures", "List all architectures for operatingsystem"
      param :operatingsystem_id, String, :desc => "id of nested operatingsystem"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @architectures = if nested_obj
                           nested_obj.architectures.search_for(*search_options).paginate(paginate_options)
                         else
                           Architecture.search_for(*search_options).paginate(paginate_options)
                         end
      end

      api :GET, "/architectures/:id/", "Show an architecture."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/architectures/", "Create an architecture."
      param :architecture, Hash, :required => true do
        param :name, String, :required => true
        param :operatingsystem_ids, Array, :desc => "Operatingsystem ID's"
      end

      def create
        @architecture = Architecture.new(params[:architecture])
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", "Update an architecture."
      param :id, :identifier, :required => true
      param :architecture, Hash, :required => true do
        param :name, String
        param :operatingsystem_ids, Array, :desc => "Operatingsystem ID's"
      end

      def update
        process_response @architecture.update_attributes(params[:architecture])
      end

      api :DELETE, "/architectures/:id/", "Delete an architecture."
      param :id, :identifier, :required => true

      def destroy
        process_response @architecture.destroy
      end
    end
  end
end
