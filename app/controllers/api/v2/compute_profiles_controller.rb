module Api
  module V2
    class ComputeProfilesController < V2::BaseController
      #before_filter :find_resource

      api :GET, "/compute_profiles", "List of Compute Profiles"
      def index
        @compute_profiles = ComputeProfile.scoped
      end

    end
  end
end
