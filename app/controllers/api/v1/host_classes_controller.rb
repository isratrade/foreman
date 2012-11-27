module Api
  module V1
    class HostClassesController < V1::BaseController
      before_filter :find_host_id, :find_puppet_id, :only => %w{create destroy}

      api :POST, "/hosts/:host_id/puppetclasses/:puppetclass_id/host_classes", "Add puppetclass to host."
      param :host_class, Hash, :required => false do
        param :host_id, String, :required => true
        param :puppetclass_id, String, :required => true
      end

      def create
        @host_class = HostClass.new(:host_id => @host.id, :puppetclass_id => @puppetclass.id)
        process_response @host_class.save!
      end

      def destroy
        @host_class = HostClass.find_by_host_id_and_puppetclass_id(@host.id, @puppetclass.id)
        process_response @host_class.destroy
      end

      private

      def find_host_id
        if @host = Host.find_by_name(params[:host_id]) || Host.find_by_id(:params[:host_id])
          @host
        else
          render_error 'not_found', :status => :not_found and return false
        end
      end

      def find_puppet_id
        if @puppetclass = Puppetclass.find_by_name(params[:puppetclass_id]) || Puppetclass.find_by_id(:params[:puppetclass_id])
          @puppetclass
        else
          render_error 'not_found', :status => :not_found and return false
        end
      end


    end
  end
end
