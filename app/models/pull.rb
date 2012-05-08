class Pull < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project
  belongs_to :repository
  
  validates_presence_of :repository_id, :base_branch, :head_branch
  
  def subject
    if self.title.present?
      subject = self.title
    else 
      subject = "Pull request ##{self.id}" 
    end
    subject
  end
end
