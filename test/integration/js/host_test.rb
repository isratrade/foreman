require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  # context - NO orgs/locations
  # PENDING - failures
  test "create new host without org or loc" do
    SETTINGS[:organizations_enabled] = false
    SETTINGS[:locations_enabled] = false
    #defaults select location1 and organization1 (no blanks)
    create_host_steps
  end

  # context - WITH orgs/locations
  # PENDING - failures
  # NoMethodError: undefined method `id' for #<Array:0x00000006c14bd8>
  # /app/models/host/managed.rb:64:in `block in <class:Managed>'
  test "create new host with org or loc" do
    SETTINGS[:organizations_enabled] = true
    SETTINGS[:locations_enabled] = true
    create_host_steps
  end

  def create_host_steps
    disable_orchestration
    fix_mismatches
    assert_new_button(hosts_path,"New Host",new_host_path)
    fill_in "host_name", :with => "foreman.test.com"
    select "Common", :from => "host_hostgroup_id"
    select "production", :from => "host_environment_id"
    click_link(:href => "#network")
    fill_in "host_mac", :with => "aa:cd:aa:bc:de:ca"
    select "mydomain.net", :from => "host_domain_id"
    fill_in "host_ip", :with => "10.7.51.73"
    click_link(:href => "#os")
    select "x86_64", :from => "host_architecture_id"
    select "centos 5.3", :from => "host_operatingsystem_id"
    click_button "Submit"
    assert page.has_selector?('h1', :text => "foreman.test.com"), "foreman.test.com was expected in the <h1> tag, but was not found"
  end

  # PENDING
  # edit, clone, delete

end
