class CreatePulls < ActiveRecord::Migration
  def self.up
    create_table :pulls, :force => true do |t|
        t.integer "project_id", :null => false
        t.integer "repository_id", :null => false
        t.string "base_branch", :null => false
        t.string "head_branch", :null => false
        t.integer "user_id", :null => false
        t.string "title", :limit => 60, :default => ""
        t.text "description", :null => false
        t.string   "status", :default => "open" # open / closed / canceled
        t.datetime "created_on", :null => false
        t.datetime "updated_on", :null => false
    end
  end

  def self.down
    drop_table :pulls
  end
end
