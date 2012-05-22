class PullItem < ActiveRecord::Base
  unloadable

  belongs_to :pull
  
end