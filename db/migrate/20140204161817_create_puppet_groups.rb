class CreatePuppetGroups < ActiveRecord::Migration
  def change
    create_table :puppet_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
