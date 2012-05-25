class PullObserver < ActiveRecord::Observer
  def after_create(pull)
    PullMailer.deliver_pull_add(pull) #if Setting.notified_events.include?('issue_added')
  end
end