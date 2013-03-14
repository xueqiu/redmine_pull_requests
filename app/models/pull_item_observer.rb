class PullItemObserver < ActiveRecord::Observer
  def after_create(item)
  	if item.item_type == 'closed'
    	PullMailer.pull_close(item).deliver
	elsif item.item_type == 'comment'
		PullMailer.pull_comment(item).deliver
	end
  end
end