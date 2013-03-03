require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'capybara/rails'

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting

    fixtures :all

    set_fixture_class({ :hosts => Host::Base })
    # Add more helper methods to be used by all tests here...

    Turn.config do |c|
     # use one of output formats:
     # :outline  - turn's original case/test outline mode [default]
     # :progress - indicates progress with progress bar
     # :dotted   - test/unit's traditional dot-progress mode
     # :pretty   - new pretty reporter
     # :marshal  - dump output as YAML (normal run mode only)
     # :cue      - interactive testing
     c.format  = :dotted
     # turn on invoke/execute tracing, enable full backtrace
     c.trace   = true
    end

    def logger
      Rails.logger
    end

    class Test::Unit::TestCase
      include RR::Adapters::TestUnit
    end

    def set_session_user
      SETTINGS[:login] ? {:user => User.admin.id, :expires_at => 5.minutes.from_now} : {}
    end

    def as_user user
      saved_user   = User.current
      User.current = users(user)
      result = yield
      User.current = saved_user
      result
    end

    def as_admin &block
      as_user :admin, &block
    end

    def setup_users
      User.current = users :admin
      user = User.find_by_login("one")
      @request.session[:user] = user.id
      @request.session[:expires_at] = 5.minutes.from_now
      user.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      user.save!
    end

    def setup_user operation, type=""
      @one = users(:one)
      as_admin do
        role = Role.find_or_create_by_name :name => "#{operation}_#{type}"
        role.permissions = ["#{operation}_#{type}".to_sym]
        @one.roles = [role]
        @one.save!
      end
      User.current = @one
    end

    def unattended?
      SETTINGS[:unattended].nil? or SETTINGS[:unattended]
    end

    def self.disable_orchestration
      #This disables the DNS/DHCP orchestration
      Host.any_instance.stubs(:boot_server).returns("boot_server")
      Resolv::DNS.any_instance.stubs(:getname).returns("foo.fqdn")
      Resolv::DNS.any_instance.stubs(:getaddress).returns("127.0.0.1")
      Net::DNS::ARecord.any_instance.stubs(:conflicts).returns([])
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(false)
      Net::DNS::PTRRecord.any_instance.stubs(:conflicting?).returns(false)
      Net::DNS::PTRRecord.any_instance.stubs(:conflicts).returns([])
      Net::DHCP::Record.any_instance.stubs(:create).returns(true)
      Net::DHCP::SparcRecord.any_instance.stubs(:create).returns(true)
      Net::DHCP::Record.any_instance.stubs(:conflicting?).returns(false)
      ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["production"])
      ProxyAPI::DHCP.any_instance.stubs(:unused_ip).returns('127.0.0.1')
    end

    def disable_orchestration
      ActiveSupport::TestCase.disable_orchestration
    end
  end


  Apipie.configuration.validate = false

  # Transactional fixtures do not work with Selenium tests, because Capybara
  # uses a separate server thread, which the transactions would be hidden
  # from. We hence use DatabaseCleaner to truncate our test database.
  DatabaseCleaner.strategy = :truncation

  class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL

    # Stop ActiveRecord from wrapping tests in transactions
    self.use_transactional_fixtures = false
  end

end



Spork.each_run do
  # This code will be run each time you run your specs.
  class ActionController::TestCase
    setup :setup_set_script_name, :set_api_user

    def setup_set_script_name
      @request.env["SCRIPT_NAME"] = @controller.config.relative_url_root
    end

    def set_api_user
      return unless self.class.to_s[/api/i]
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:apiadmin).login, "secret")
    end
  end

  class ActionDispatch::IntegrationTest

    def setup
      login_admin
    end

    teardown do
      DatabaseCleaner.clean       # Truncate the database
      Capybara.reset_sessions!    # Forget the (simulated) browser state
      Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
    end

    private

    def login_admin
      visit "/"
      fill_in "login_login", :with => "admin"
      fill_in "login_password", :with => "secret"
      click_button "Login"
    end

    def logout_admin
      click_link "Sign Out"
    end

  end

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.
