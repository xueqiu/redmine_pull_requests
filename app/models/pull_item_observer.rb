class PullItemObserver < ActiveRecord::Observer
  def after_create(item)
	if item.item_type == 'comment'
		PullMailer.pull_comment(item).deliver
  	elsif (item.item_type == 'closed' || item.item_type == 'reviewed')
    	PullMailer.pull_status_change(item).deliver
	end
  end
end