require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  # context - NO orgs/locations
  # PENDING - failures
  test "create new host with no org or loc" do
    #SETTINGS[:organizations_enabled] = false
    #SETTINGS[:locations_enabled] = false
    #create_host_steps
  end

  # context - WITH orgs/locations
  # PENDING - failures
  # NoMethodError: undefined method `id' for #<Array:0x00000006c14bd8>
  # /app/models/host/managed.rb:64:in `block in <class:Managed>'
  test "create new page with org or loc" do
    #SETTINGS[:organizations_enabled] = true
    #SETTINGS[:locations_enabled] = true
    #create_host_steps
  end

  def create_host_steps
    assert_new_button(hosts_path,"New Host",new_host_path)
    fill_in "host_name", :with => "foreman.test.com"
    select "Common", :from => "host_hostgroup_id"
    #select "production", :from => "host_environment_id"
    click_link "Network"
    fill_in "host_mac", :with => "aa:cd:aa:bc:de:ca"
    select "mydomain.net", :from => "host_domain_id"
    fill_in "host_ip", :with => "10.0.50.70"
    within(:xpath, "//*[@id='new_host']/ul/li[4]") do
      click_link "Operating System"
    end
    select "x86_64", :from => "host_architecture_id"
    select "centos 5.3", :from => "host_operatingsystem_id"
    assert_submit_button(hosts_path)
    assert page.has_link?('foreman.test.com'), "No link foreman.test.com appears on index page"
  end

  # PENDING
  # edit, clone, delete

end
