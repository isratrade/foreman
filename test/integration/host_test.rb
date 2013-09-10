require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(hosts_path,"Hosts","New Host")
  end

  test "create new page" do
    assert_new_button(hosts_path,"New Host",new_host_path)
    assert page.has_link?("Host", :href => "#primary")
    assert page.has_link?("Network", :href => "#network")
    assert page.has_link?("Operating System", :href => "#os")
    assert page.has_link?("Parameters", :href => "#params")
    assert page.has_link?("Additional Information", :href => "#info")
  end

  test "show page" do
    visit hosts_path
    click_link "my5name.mydomain.net"
    assert page.has_selector?('h1', :text => "my5name.mydomain.net"), "my5name.mydomain.net <h1> tag, but was not found"
    assert page.has_link?("Properties", :href => "#properties")
    assert page.has_link?("Metrics", :href => "#metrics")
    assert page.has_link?("Templates", :href => "#template")
    assert page.has_link?("Edit", :href => "/hosts/my5name.mydomain.net/edit")
    assert page.has_link?("Build", :href => "/hosts/my5name.mydomain.net/setBuild")
    assert page.has_link?("Run puppet", :href => "/hosts/my5name.mydomain.net/puppetrun")
    assert page.has_link?("Delete", :href => "/hosts/my5name.mydomain.net")
  end

end
