module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2
      before_filter :set_metadata_pagination, :only => :index

      resource_description do
        resource_id "v2_base" # to avoid conflicts with V1::BaseController
        api_version "v2"
      end

      def set_metadata_pagination
        @per_page = 77
        # params[:per_page] if params[:per_page]
        # unless @per_page
        #   klass = controller_name.split('/').last.classify
        #   klass = "Host::Base" if klass == "Host"
        #   @per_page ||= klass.constantize.per_page
        # end
        # @page = params[:page] || 1
      end

    end
  end
end
