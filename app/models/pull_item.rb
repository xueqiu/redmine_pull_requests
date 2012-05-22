class PullItem < ActiveRecord::Base
  unloadable

  belongs_to :pull
  belongs_to :user
  
end