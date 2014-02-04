class AddSortNetworkId < ActiveRecord::Migration
  def up
    add_column :subnets, :sort_network_id, :integer

    # migrate existing
    Subnet.scoped.each do |subnet|
     subnet.update_attribute(:sort_network_id, IPAddr.new(subnet.network).to_i)
    end
  end

  def down
    remove_column :subnets, :sort_network_id
  end

end
