class API_v1 < Grape::API
  version 'v1', :using => :path, :vendor => 'foreman', :format => :json
  resource :system do
    desc "Returns pong."
    get :ping do
      { :ping => "pong" }
    end
    desc "Raises an exception."
    get :raise do
      raise "Unexpected error."
    end
  end
end