class Pull < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project
  belongs_to :repository
  
  has_many :items, :class_name => "PullItem"
  
  validates_presence_of :repository_id, :base_branch, :head_branch

  scope :with_status, lambda { |status|
    { :conditions => { :status => status } }
  }

  acts_as_watchable
  attr_accessible :base_branch, :head_branch, :title, 
                  :description, :status, :watcher_user_ids
  
  def subject
    if self.title.present?
      subject = self.title
    else 
      subject = "Pull request ##{self.id}"
    end
    subject
  end
  
  def item(status)
    PullItem.with_status(id, status)
  end

  def comment(conetent)
    items.create(:item_type => "comment", :user_id => User.current.id, :content => conetent)
  end
  
  def review_by(user_id = User.current.id)
    unless item('reviewed').length > 0
      items.create(:item_type => "reviewed", :user_id => user_id)
    end
  end
  
  def merge_by(user_id = User.current.id)
    unless item('merged').length > 0
      repository.merge(base_branch, head_branch)
    
      items.create(:item_type => "merged", :user_id => user_id)
      items.create(:item_type => "closed", :user_id => user_id)
    end
  end

  def close_by(user_id = User.current.id)
    unless item('closed').length > 0
      items.create(:item_type => "closed", :user_id => user_id)
    end
  end
  
  def self.auto_close
    Pull.with_status("open").each do |pull|
      repo = pull.repository
      
      changesets = repo.latest_changesets('', pull.base_branch, 1)
      changeset = changesets.first if changesets.length > 0

      if changeset.present?
        merge_from_branch = ''
        msg = changeset.comments 
        if msg
          matched = msg.scan(/(Merge branch ')(.*)('.*)/)
          merge_from_branch = matched[0][-2] if matched.length > 0
        end
        #matched_merge_pull = matched_merge(pull.base_branch, pull.head_branch)
        matched_merge_pull = Pull.find(:first, :conditions => [ "status = 'open' and base_branch = ? and head_branch = ?", 
                                                                pull.base_branch, merge_from_branch ])
        if matched_merge_pull.present?
          matched_merge_pull.update_attributes(:status => "closed")
          matched_merge_pull.merge_by(changeset.user_id)
        end
      end
    end
  end
end
