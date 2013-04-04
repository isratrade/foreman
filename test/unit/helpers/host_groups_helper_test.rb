require 'test_helper'

class HostGroupsHelperTest < ActionView::TestCase
  include ActionView::Helpers::TagHelper
  include HostsAndHostgroupsHelper
  include ApplicationHelper

  test "should have the full string of the parent class if the child is a substring" do
    test_group = Hostgroup.create(:name => "test/st")
    skip("This fails in 1.8.7 only")
    assert hostgroup_name(test_group).include?("test/st")
    assert !hostgroup_name(test_group).include?("te/st")
  end
end
