module Api
  module V2
    class OperatingsystemsController < V2::BaseController

      resource_description do
        name 'Operating systems'
      end

      before_filter :find_resource, :only => %w{show edit update destroy bootfiles}

      api :GET, "/operatingsystems/", "List all operating systems."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @operatingsystems = Operatingsystem.
          includes(:media, :architectures, :ptables, :config_templates, :os_default_templates).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/operatingsystems/:id/", "Show an OS."
      param :id, String, :required => true

      def show
      end

      def_param_group :operatingsystem do
        param :operatingsystem, Hash, :required => true do
          param :name, /\A(\S+)\Z/, :required => true
          param :major, String, :required => true
          param :minor, String, :required => true
          param :description, String
          param :family, String
          param :release_name, String
          param :architecture_ids, Array, :desc => 'architecture IDs'
          param :media_ids, Array, :desc => 'media IDs'
          param :ptable_ids, Array, :desc => 'partition table IDs'
          param :config_template_ids, Array, :desc => 'config template IDs'
          param :parameter_ids, Array, :desc => 'config template IDs'
        end
      end

      api :POST, "/operatingsystems/", "Create an OS."
      param_group :operatingsystem

      def create
        @operatingsystem = Operatingsystem.new(params[:operatingsystem])
        process_response @operatingsystem.save
      end

      api :PUT, "/operatingsystems/:id/", "Update an OS."
      param :id, String, :required => true
      param_group :operatingsystem

      def update
        process_response @operatingsystem.update_attributes(params[:operatingsystem])
      end

      api :DELETE, "/operatingsystems/:id/", "Delete an OS."
      param :id, String, :required => true

      def destroy
        process_response @operatingsystem.destroy
      end

      api :GET, "/operatingsystems/:id/bootfiles/", "List boot files an OS."
      param :id, String, :required => true
      param :medium, String
      param :architecture, String

      def bootfiles
        medium = Medium.find_by_name(params[:medium])
        arch   = Architecture.find_by_name(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render :json => e.to_s, :status => :unprocessable_entity
      end

      api :GET, "/operatingsystems/:id/parameters", "List all parameters for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only.
      def parameters
      end

      api :GET, "/operatingsystems/:id/media", "List all media for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def media
      end

      api :GET, "/operatingsystems/:id/ptables", "List all ptables for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def ptables
      end

      api :GET, "/operatingsystems/:id/config_templates", "List all config_templates for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def config_templates
      end

      api :GET, "/operatingsystems/:id/architectures", "List all architectures for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def architectures
      end

      api :GET, "/operatingsystems/:id/hosts", "List all hosts for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def hosts
      end

      api :GET, "/operatingsystems/:id/hostgroups", "List all hostgroups for an operating system."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      # action for documentation purposes only
      def hostgroups
      end

    end
  end
end
