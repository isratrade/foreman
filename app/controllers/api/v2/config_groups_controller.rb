module Api
  module V2
    class ConfigGroupsController < V2::BaseController
      #before_filter :find_resource

      api :GET, "/config_groups", "List of Config Groups"
      def index
        @config_groups = ConfigGroup.scoped
      end

    end
  end
end
