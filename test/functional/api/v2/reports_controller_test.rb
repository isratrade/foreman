require 'test_helper'

class Api::V2::ReportsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end

  test "should show individual record" do
    get :show, { :id => reports(:report).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, { :id => reports(:report).to_param }
    end
    assert_response :success
  end

  test "should get reports for given host only" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
    assert_equal 1, reports.count
  end

  test "should return empty result for host with no reports" do
    get :index, {:host_id => hosts(:two).to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert reports.empty?
    assert_equal 0, reports.count
  end

  test "should get last report" do
    get :last
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
  end

  test "should get last report for given host only" do
    get :last, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
  end

  test "should give error if no last report for given host" do
    get :last, {:host_id => hosts(:two).to_param }
    assert_response 500
  end

  describe Report do
    def setup
      User.current = users(:one) #use an unpriviledged user, not apiadmin
    end

    def create_a_puppet_transaction_report
      @log ||= JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/../../../fixtures/report-empty.json")))
    end

    def test_create_valid
      User.current=nil
      post :create, {:report => create_a_puppet_transaction_report }, set_session_user
      assert_response :success
    end

    def test_create_invalid
      User.current=nil
      post :create, {:report => ["not a hash", "throw an error"]  }, set_session_user
      assert_response :unprocessable_entity
    end

    def test_create_duplicate
      User.current=nil
      post :create, {:report => create_a_puppet_transaction_report }, set_session_user
      assert_response :success
      post :create, {:report => create_a_puppet_transaction_report }, set_session_user
      assert_response :unprocessable_entity
    end

    test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to create a report' do
      Setting[:restrict_registered_puppetmasters] = false
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, {:report => create_a_puppet_transaction_report }
      assert_response :success
    end

    test 'hosts with a registered smart proxy on should create a report successfully' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, {:report => create_a_puppet_transaction_report }
      assert_response :success
    end

    test 'hosts without a registered smart proxy on should not be able to create a report' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = false

      Resolv.any_instance.stubs(:getnames).returns(['another.host'])
      post :create, {:report => create_a_puppet_transaction_report }
      assert_equal 403, @response.status
    end

    test 'hosts with a registered smart proxy and SSL cert should create a report successfully' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, {:report => create_a_puppet_transaction_report }
      assert_response :success
    end

    test 'hosts without a registered smart proxy but with an SSL cert should not be able to create a report' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, {:report => create_a_puppet_transaction_report }
      assert_equal 403, @response.status
    end

    test 'hosts with an unverified SSL cert should not be able to create a report' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
      post :create, {:report => create_a_puppet_transaction_report }
      assert_equal 403, @response.status
    end

    test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to create a report' do
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = true
      SETTINGS[:require_ssl] = true

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, {:report => create_a_puppet_transaction_report }
      assert_equal 403, @response.status
    end

    test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to create reports' do
      # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
      Setting[:restrict_registered_puppetmasters] = true
      Setting[:require_ssl_puppetmasters] = true
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, {:report => create_a_puppet_transaction_report }
      assert_response :success
    end
  end
end
