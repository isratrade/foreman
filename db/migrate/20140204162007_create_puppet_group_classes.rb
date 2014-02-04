class CreatePuppetGroupClasses < ActiveRecord::Migration
  def change
    create_table :puppet_group_classes do |t|
      t.integer :puppetclass_id
      t.integer :puppet_group_id

      t.timestamps
    end
  end
end
