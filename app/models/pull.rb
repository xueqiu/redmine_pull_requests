class Pull < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project
  belongs_to :repository
end
