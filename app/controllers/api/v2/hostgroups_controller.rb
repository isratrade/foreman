module Api
  module V2
    class HostgroupsController < V1::HostgroupsController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_nested_object, :only => [:index]

      def index
        if nested_obj
          @hostgroups = nested_obj.hostgroups.search_for(*search_options).paginate(paginate_options)
          render :template => "api/v2/hostgroups/index"
        else
          super
          render :template => "api/v1/hostgroups/index"
        end
      end

      def show
        super
        render :template => "api/v1/hostgroups/show"
      end

      private
      attr_reader :nested_obj

      def find_nested_object
        params.keys.each do |param|
          if param =~ /(\w+)_id$/
            resource_identifying_attributes.each do |key|
              find_method = "find_by_#{key}"
              @nested_obj ||= $1.capitalize.constantize.send(find_method, params[param])
            end
          end
        end
        return @nested_obj
      end

    end
  end
end
