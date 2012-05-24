class Pull < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project
  belongs_to :repository
  
  has_many :items, :class_name => "PullItem"
  
  validates_presence_of :repository_id, :base_branch, :head_branch

  named_scope :with_status, lambda { |status|
    { :conditions => { :status => status } }
  }
  
  named_scope :matched_merge, lambda { |base_branch, head_branch|
    { :conditions => [ "status = 'open' and base_branch = ? and head_branch = ?", base_branch, head_branch ] }
  }
  
  def subject
    if self.title.present?
      subject = self.title
    else 
      subject = "Pull request ##{self.id}"
    end
    subject
  end
  
  def self.review_by(user_id = User.current.id)
      items.create(:item_type => "reviewed", :user_id => user_id)
  end
  
  def merge_by(user_id = User.current.id)
    repository.merge(base_branch, head_branch)
    
    items.create(:item_type => "merged", :user_id => user_id)
    items.create(:item_type => "closed", :user_id => user_id)
  end

  def close_by(user_id = User.current.id)
    items.create(:item_type => "closed", :user_id => user_id)
  end
  
  def self.auto_close
    Pull.with_status("open").each do |pull|
      repo = pull.repository
      
      changesets = repo.latest_changesets('', pull.base_branch, 1)
      changeset = changesets.first if changesets.length > 0

      if changeset.present?
        merge_from_branch = ''
        msg = changeset.comments 
        if msg and msg.index('Merge')
          merge_from_branch = msg.split(' ').last
        end
        #matched_merge_pull = matched_merge(pull.base_branch, pull.head_branch)
        matched_merge_pull = Pull.find(:first, :conditions => [ "status = 'open' and base_branch = ? and head_branch = ?", 
                                                                pull.base_branch, pull.head_branch ])
        if matched_merge_pull.present?
          matched_merge_pull.update_attributes(:status => "closed")
          matched_merge_pull.merge_by(changeset.user_id)
        end
      end
    end
  end
end
