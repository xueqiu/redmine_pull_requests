class PullItemObserver < ActiveRecord::Observer
  def after_create(item)
  	if item.item_type == 'closed'
    	PullMailer.deliver_pull_close(item) #if Setting.notified_events.include?('issue_added')
	end
  end
end