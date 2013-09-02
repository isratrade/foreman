module Api
  module V2
    class EnvironmentsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_optional_nested_object, :only => [:index]

      api :GET, "/environments/", "List all environments."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if nested_obj
          @environments = nested_obj.environments.search_for(*search_options).paginate(paginate_options)
        else
          @environments = Environment.search_for(*search_options).paginate(paginate_options)
        end
      end

      api :GET, "/environments/:id/", "Show an environment."
      param :id, :identifier, :required => true

      def show
      end

      def create
        @environment = Environment.new(params[:environment])
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", "Update an environment."
      param :id, :identifier, :required => true
      param :environment, Hash, :required => true do
        param :name, String
      end

      def update
        process_response @environment.update_attributes(params[:environment])
      end

      api :DELETE, "/environments/:id/", "Delete an environment."
      param :id, :identifier, :required => true

      def destroy
        process_response @environment.destroy
      end

      private

      def allowed_nested_id
        %w(puppetclass_id host_id hostgroup_id)
      end

    end
  end
end
