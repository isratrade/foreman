require 'test_helper'

class HostConfigGroupTest < ActiveSupport::TestCase

  test 'host group_puppetclasses' do
    host = hosts(:one)
    assert_equal 4, host.group_puppetclasses.count
    assert_equal ['auth', 'chkmk', "nagios", 'pam'], host.group_puppetclasses.pluck(:name).sort
  end

  test 'host config_groups' do
    host = hosts(:one)
    assert_equal 2, host.config_groups.count
    assert_equal ['Monitoring', 'Security'], host.config_groups.pluck(:name).sort
  end

  test 'hostgroup group_puppetclasses' do
    hostgroup = hostgroups(:common)
    assert_equal 2, hostgroup.group_puppetclasses.count
    assert_equal ['chkmk', "nagios"], hostgroup.group_puppetclasses.pluck(:name).sort
  end

  test 'hostgroup config_groups' do
    hostgroup = hostgroups(:common)
    assert_equal 1, hostgroup.config_groups.count
    assert_equal ['Monitoring'], hostgroup.config_groups.pluck(:name)
  end


end
