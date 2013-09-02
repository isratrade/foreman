module Api
  module Version2
    extend ActiveSupport::Concern

    included do
      layout 'api/v2/layouts/v2_metadata_layout', :only => :index
    end

    def api_version
      '2'
    end

  end
end