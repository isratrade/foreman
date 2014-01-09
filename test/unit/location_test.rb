require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test 'it should not save without an empty name' do
    location = Location.new
    assert !location.save
  end

  test 'it should not save with a blank name' do
    location = Location.new
    location.name = "      "
    assert !location.save
  end

  test 'it should not save another location with the same name' do
    location = Location.new
    location.name = "location1"
    assert location.save

    second_location = Location.new
    second_location.name = "location1"
    assert !second_location.save
  end

  test 'it should show the name for to_s' do
    location = Location.new :name => "location name"
    assert location.to_s == "location name"
  end

  test 'location is invalid without any taxable_taxonomies' do
    # no taxable_taxonomies in fixtures
    # no ignore_types in fixtures
    location = taxonomies(:location1)
    assert !location.valid?
  end

  test 'location is valid if ignore all types' do
    location = taxonomies(:location1)
    location.organization_ids = [taxonomies(:organization1).id]
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    assert location.valid?
  end

  test 'location is valid after fixture mismatches' do
    location = taxonomies(:location1)
    Taxonomy.all_import_missing_ids
    assert location.valid?
  end

  test 'it should return array of used ids by hosts' do
    location = taxonomies(:location1)
    # run used_ids method
    used_ids = location.used_ids
    # get results from Host object
    environment_ids = Host.where(:location_id => location.id).pluck(:environment_id).compact.uniq
    hostgroup_ids = Host.where(:location_id => location.id).pluck(:hostgroup_id).compact.uniq
    subnet_ids = Host.where(:location_id => location.id).pluck(:subnet_id).compact.uniq
    domain_ids = Host.where(:location_id => location.id).pluck(:domain_id).compact.uniq
    medium_ids = Host.where(:location_id => location.id).pluck(:medium_id).compact.uniq
    compute_resource_ids = Host.where(:location_id => location.id).pluck(:compute_resource_id).compact.uniq
    user_ids = Host.where(:location_id => location.id).where(:owner_type => 'User').pluck(:owner_id).compact.uniq
    smart_proxy_ids = Host.where(:location_id => location.id).map {|host| host.smart_proxies.map(&:id)}.flatten.compact.uniq
    config_template_ids = Host.where("location_id = #{location.id} and operatingsystem_id > 0").map {|host| host.configTemplate.try(:id)}.compact.uniq
    # match to above retrieved data
    assert_equal used_ids[:environment_ids], environment_ids
    assert_equal used_ids[:hostgroup_ids], hostgroup_ids
    assert_equal used_ids[:subnet_ids], subnet_ids
    assert_equal used_ids[:domain_ids], domain_ids
    assert_equal used_ids[:medium_ids], medium_ids
    assert_equal used_ids[:compute_resource_ids], compute_resource_ids
    assert_equal used_ids[:user_ids].sort, user_ids.sort
    assert_equal used_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
    assert_equal used_ids[:config_template_ids], config_template_ids
    # match to raw fixtures data
    assert_equal used_ids[:environment_ids].sort, Array(environments(:production).id).sort
    assert_equal used_ids[:hostgroup_ids].sort, Array.new
    assert_equal used_ids[:subnet_ids].sort, Array(subnets(:one).id).sort
    assert_equal used_ids[:domain_ids].sort, Array([domains(:yourdomain).id, domains(:mydomain).id]).sort
    assert_equal used_ids[:medium_ids].sort, Array(media(:one).id).sort
    assert_equal used_ids[:compute_resource_ids].sort, Array(compute_resources(:one).id).sort
    assert_equal used_ids[:user_ids], [users(:restricted).id]
    assert_equal used_ids[:smart_proxy_ids].sort, Array([smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:puppetmaster).id]).sort
    assert_equal used_ids[:config_template_ids].sort, Array(config_templates(:mystring2).id).sort
  end

  test 'it should return selected_ids array of selected values only (when types are not ignored)' do
    location = taxonomies(:location1)
    #fixtures for taxable_taxonomies don't work, on has_many :through polymorphic
    # so I created assocations here.
    location.subnet_ids = Array(subnets(:one).id)
    location.smart_proxy_ids = Array(smart_proxies(:puppetmaster).id)
    # run selected_ids method
    selected_ids = location.selected_ids
    # get results from taxable_taxonomies
    environment_ids = location.environments.pluck('environments.id')
    hostgroup_ids = location.hostgroups.pluck('hostgroups.id')
    subnet_ids = location.subnets.pluck('subnets.id')
    domain_ids = location.domains.pluck('domains.id')
    medium_ids = location.media.pluck('media.id')
    user_ids = location.users.pluck('users.id')
    smart_proxy_ids = location.smart_proxies.pluck('smart_proxies.id')
    config_template_ids = location.config_templates.pluck('config_templates.id')
    compute_resource_ids = location.compute_resources.pluck('compute_resources.id')
    # check if they match
    assert_equal selected_ids[:environment_ids], environment_ids
    assert_equal selected_ids[:hostgroup_ids], hostgroup_ids
    assert_equal selected_ids[:subnet_ids], subnet_ids
    assert_equal selected_ids[:domain_ids], domain_ids
    assert_equal selected_ids[:medium_ids], medium_ids
    assert_equal selected_ids[:user_ids], user_ids
    assert_equal selected_ids[:smart_proxy_ids], smart_proxy_ids
    assert_equal selected_ids[:config_template_ids], config_template_ids
    assert_equal selected_ids[:compute_resource_ids], compute_resource_ids
    # match to manually generated taxable_taxonomies
    assert_equal selected_ids[:environment_ids], Array(environments(:production).id)
    assert_equal selected_ids[:hostgroup_ids], Array.new
    assert_equal selected_ids[:subnet_ids].sort, Array(subnets(:one).id)
    assert_equal selected_ids[:domain_ids], Array.new
    assert_equal selected_ids[:medium_ids], Array.new
    assert_equal selected_ids[:user_ids], Array.new
    assert_equal selected_ids[:smart_proxy_ids].sort, Array(smart_proxies(:puppetmaster).id)
    assert_equal selected_ids[:config_template_ids], Array.new
    assert_equal selected_ids[:compute_resource_ids], Array.new
  end

  test 'it should return selected_ids array of ALL values (when types are ignored)' do
    location = taxonomies(:location1)
    # ignore all types
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    # run selected_ids method
    selected_ids = location.selected_ids
    # should return all when type is ignored
    assert_equal selected_ids[:environment_ids], Environment.pluck(:id)
    assert_equal selected_ids[:hostgroup_ids], Hostgroup.pluck(:id)
    assert_equal selected_ids[:subnet_ids], Subnet.pluck(:id)
    assert_equal selected_ids[:domain_ids], Domain.pluck(:id)
    assert_equal selected_ids[:medium_ids], Medium.pluck(:id)
    assert_equal selected_ids[:user_ids], User.pluck(:id)
    assert_equal selected_ids[:smart_proxy_ids], SmartProxy.pluck(:id)
    assert_equal selected_ids[:config_template_ids], ConfigTemplate.pluck(:id)
    assert_equal selected_ids[:compute_resource_ids], ComputeResource.pluck(:id)
  end

  #Clone
  test "it should clone location with all associations" do
    location = taxonomies(:location1)
    location_dup = location.dup
    location_dup.name = "location_dup_name"
    assert location_dup.save!
    assert_equal, location_dup.environment_ids = location.environment_ids
    assert_equal, location_dup.hostgroup_ids = location.hostgroup_ids
    assert_equal, location_dup.subnet_ids = location.subnet_ids
    assert_equal, location_dup.domain_ids = location.domain_ids
    assert_equal, location_dup.medium_ids = location.medium_ids
    assert_equal, location_dup.user_ids = location.user_ids
    assert_equal, location_dup.smart_proxy_ids = location.smart_proxy_ids
    assert_equal, location_dup.config_template_ids = location.config_template_ids
    assert_equal, location_dup.compute_resource_ids = location.compute_resource_ids
    assert_equal, location_dup.organization_ids = location.organization_ids
  end

  #Audit
  test "it should have auditable_type as Location rather Taxonomy" do
    location = taxonomies(:location2)
    assert location.update_attributes!(:name => 'newname')
    assert_equal 'Location', Audit.unscoped.last.auditable_type
  end

  #Location inheritance tests
  test "inherited location should have correct label" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    assert_equal "Location 1/rack1", location.label
  end

  test "inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # check that inherited_ids of location matches selected_ids of parent
    location.inherited_ids.each do |k,v|
      assert_equal v.uniq, parent.selected_ids[k].uniq
    end
  end

  test "selected_or_inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # add subnet to location
    assert TaxableTaxonomy.create(:taxonomy_id => location.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
    # check that inherited_ids of location matches selected_ids of parent, except for subnet
    location.selected_or_inherited_ids.each do |k,v|
      assert_equal v.uniq, parent.selected_ids[k].uniq unless k == 'subnet_ids'
      assert_equal v.uniq, ([subnets(:two).id] + parent.selected_ids[k].uniq) if k == 'subnet_ids'
    end
    # check that inherited_ids of location matches selected_ids of parent
  end

  test "used_and_selected_or_inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # check that inherited_ids of location matches selected_ids of parent
    location.used_and_selected_or_inherited_ids.each do |k,v|
      assert_equal v.uniq, parent.used_and_selected_ids[k].uniq
    end
  end

  test "need_to_be_selected_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # no hosts were assigned to location, so no missing ids need to be selected
    location.need_to_be_selected_ids.each do |k,v|
      assert v.empty?
    end
  end

  test "multiple inheritence" do
    parent1 = taxonomies(:location1)
    assert_equal [subnets(:one).id], parent1.selected_ids["subnet_ids"]

    # inherit from parent 1
    parent2 = Location.create :name => "floor1", :parent_id => parent1.id
    assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
    assert_equal [subnets(:one).id, subnets(:two).id].sort, parent2.selected_or_inherited_ids["subnet_ids"].sort

    # inherit from parent 2
    location = Location.create :name => "rack1", :parent_id => parent2.id
    assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:three).id, :taxable_type => "Subnet")
    assert_equal [subnets(:one).id, subnets(:two).id, subnets(:three).id].sort, location.selected_or_inherited_ids["subnet_ids"].sort
   end

  test "cannot delete location that is a parent for nested location" do
    parent1 = taxonomies(:location2)
    location = Location.create :name => "floor1", :parent_id => parent1.id
    assert_raise Ancestry::AncestryException do
      parent1.destroy
    end
  end

end
