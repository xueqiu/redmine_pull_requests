class PullItemObserver < ActiveRecord::Observer
  def after_create(item)
  	if item.item_type == 'closed'
    	PullMailer.deliver_pull_close(item)
	elsif item.item_type == 'comment'
		PullMailer.deliver_pull_comment(item)
	end
  end
end