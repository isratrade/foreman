class CreateHostPuppetGroups < ActiveRecord::Migration
  def change
    create_table :host_puppet_groups do |t|
      t.integer :puppet_group_id
      t.integer :host_id
      t.string  :host_type

      t.timestamps
    end
  end
end
