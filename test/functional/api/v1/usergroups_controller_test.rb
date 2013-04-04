require 'test_helper'

class Api::V1::UsergroupsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_usergroup' }

  test "should get index" do
    get :index, { }
    assert_response :success
    refute_nil assigns(:usergroups)
    usergroups = ActiveSupport::JSON.decode(@response.body)
    assert !usergroups.empty?
  end

  test "should show individual record" do
    get :show, { :id => usergroups(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, { :usergroup => valid_attrs }
    end
    assert_response :success
  end

  test "should update usergroup" do
    put :update, { :id => usergroups(:one).to_param, :usergroup => { } }
    assert_response :success
  end

  test "should destroy usergroups" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, { :id => usergroups(:one).to_param }
    end
    assert_response :success
  end

end
