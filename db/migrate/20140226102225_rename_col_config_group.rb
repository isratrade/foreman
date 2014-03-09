class RenameColConfigGroup < ActiveRecord::Migration
  def change
    rename_column :config_group_classes, :puppet_group_id, :config_group_id
    rename_column :host_config_groups, :puppet_group_id, :config_group_id
  end

end
