class AddPullsAndPullItemsIndex < ActiveRecord::Migration
  def self.up
	add_index "pulls", "status", :name => "index_status"
	add_index "pulls", "project_id", :name => "index_project_id"

	add_index "pull_items", "pull_id", :name => "index_pull_id"
	add_index "pull_items", "item_type", :name => "index_item_type"
  end

  def self.down
    remove_index "pulls", "index_status"
    remove_index "pulls", "index_project_id"

    remove_index "pull_items", "index_pull_id"
    remove_index "pull_items", "index_item_type"
  end
end