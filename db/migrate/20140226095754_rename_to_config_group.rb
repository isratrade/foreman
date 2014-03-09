class RenameToConfigGroup < ActiveRecord::Migration
  def change
    rename_table :puppet_groups, :config_groups
    rename_table :puppet_group_classes, :config_group_classes
    rename_table :host_puppet_groups, :host_config_groups
  end
end
