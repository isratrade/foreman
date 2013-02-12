module Api
  module V2
    class HostsController < V1::HostsController

      before_filter :setup_search_options, :only => :index

      def index
        super
        render :template => "api/v1/hosts/index"
      end

      def show
        render :template => "api/v1/hosts/show"
      end

    end
  end
end
