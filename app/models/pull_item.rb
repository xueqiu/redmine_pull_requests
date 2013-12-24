class PullItem < ActiveRecord::Base
  unloadable

  belongs_to :pull
  belongs_to :user
  
  scope :with_status, -> (pull_id, status) { :conditions => { :pull_id => pull_id, :item_type => status } }
  
end