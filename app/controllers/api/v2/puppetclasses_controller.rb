module Api
  module V2
    class PuppetclassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_optional_nested_object, :only => [:index, :show]

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
        values   = Puppetclass.search_for(*search_options) unless nested_obj
        values ||= case nested_obj
                     when Host::Base, Hostgroup
                       #NOTE: no search_for on array generated by all_puppetclasses
                       nested_obj.all_puppetclasses
                     else
                       nested_obj.puppetclasses.search_for(*search_options)
                   end
        @total   = Puppetclass.count unless nested_obj
        @total ||= case nested_obj
                     when Host::Base, Hostgroup
                       values.count
                     else
                       nested_obj.puppetclasses.count
                   end
        @subtotal = values.count
        @puppetclasses = Puppetclass.classes2hash_v2(values.paginate(paginate_options))
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

      def_param_group :puppetclass do
        param :puppetclass, Hash, :required => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/puppetclasses/", "Create a puppetclass."
      param_group :puppetclass

      def create
        @puppetclass = Puppetclass.new(params[:puppetclass])
        process_response @puppetclass.save
      end

      api :PUT, "/puppetclasses/:id/", "Update a puppetclass."
      param :id, String, :required => true
      param_group :puppetclass

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
