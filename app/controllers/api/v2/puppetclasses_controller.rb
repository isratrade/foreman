module Api
  module V2
    class PuppetclassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_optional_nested_object, :only => [:index]

      api :GET, "/puppetclasses/", "List all puppetclasses."
      api :GET, "/hosts/:host_id/puppetclasses", "List all puppetclasses for host"
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses", "List all puppetclasses for hostgroup"
      api :GET, "/environments/:environment_id/puppetclasses", "List all puppetclasses for environment"
      param :host_id, String, :desc => "id of nested host"
      param :hostgroup_id, String, :desc => "id of nested hostgroup"
      param :environment_id, String, :desc => "id of nested environment"
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if @nested_obj
          if @nested_obj.kind_of?(Environment)
            values = @nested_obj.puppetclasses.search_for(*search_options).paginate(paginate_options)
          elsif #host or hostgroup
            # note: no search_for for array
            values = @nested_obj.all_puppetclasses.paginate(paginate_options)
          end
        else
          values = Puppetclass.search_for(*search_options).paginate(paginate_options)
        end
        render :json => Puppetclass.classes2hash(values)
      end

      api :GET, "/puppetclasses/:id", "Show a puppetclass"
      api :GET, "/hosts/:host_id/puppetclasses/:id", "Show a puppetclass for host"
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses/:id", "Show a puppetclass for hostgroup"
      api :GET, "/environments/:environment_id/puppetclasses/:id", "Show a puppetclass for environment"
      param :host_id, String, :desc => "id of nested host"
      param :hostgroup_id, String, :desc => "id of nested hostgroup"
      param :environment_id, String, :desc => "id of nested environment"
      param :id, String, :required => true, :desc => "id of puppetclass"

      def show
      end

      api :POST, "/puppetclasses/", "Create a puppetclass."
      param :puppetclass, Hash, :required => true do
        param :name, String, :required => true
      end

      def create
        @puppetclass = Puppetclass.new(params[:puppetclass])
        process_response @puppetclass.save
      end

      api :PUT, "/puppetclasses/:id/", "Update a puppetclass."
      param :id, String, :required => true
      param :puppetclass, Hash, :required => true do
        param :name, String
      end

      def update
        process_response @puppetclass.update_attributes(params[:puppetclass])
      end

      api :DELETE, "/puppetclasses/:id/", "Delete a puppetclass."
      param :id, String, :required => true

      def destroy
        process_response @puppetclass.destroy
      end

      private

      def allowed_nested_id
        %w(environment_id host_id hostgroup_id)
      end

    end
  end
end
