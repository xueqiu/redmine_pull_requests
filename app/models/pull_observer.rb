class PullObserver < ActiveRecord::Observer
  def after_create(pull)
    PullMailer.pull_add(pull).deliver #if Setting.notified_events.include?('issue_added')
  end 
end