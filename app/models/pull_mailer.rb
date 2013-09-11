class PullMailer < Mailer
  
  def pull_add(pull)
    save_watchers(pull)
    @user = pull.user    

    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user

    message_id pull
    recipients = find_recipients(pull)
    subject = "[#{pull.project.name} - Pull request ##{pull.id}] #{pull.title}"
    @pull = pull
    @pull_url = url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    
    mail :to => recipients, :subject => subject
  end
  
  def pull_status_change(item)
    pull = item.pull
    @user = item.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients = find_recipients(pull)
    subject = "[#{pull.project.name} - Pull request ##{pull.id}] (#{item.item_type.camelize}) #{pull.title}"
    @pull = pull
    @item = item
    @pull_url = url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    mail :to => recipients, :subject => subject
  end

  def pull_comment(item)
    pull = item.pull
    @user = item.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients = find_recipients(pull)
    subject = "[#{pull.project.name} - Pull request ##{pull.id}] (#{item.item_type.camelize}) #{pull.title}"
    @pull = pull
    @item = item
    @pull_url = url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    mail :to => recipients, :subject => subject
  end

  private
  def find_recipients(pull)
    default = Setting.plugin_redmine_pull_requests['default_sent_to_email']

    recipients = pull.watcher_recipients
    unless recipients && recipients.size > 0
        repo = pull.repository
        # get active user only
        recipients = User.find_all_by_id_and_status(repo.committers.collect(&:last).collect(&:to_i), 1).collect(&:mail)
    end

    recipients += [default] if !recipients.include?(default)
    recipients
  end

  def save_watchers(pull)
    pull.add_watcher(pull.user)
    watcher_user_ids = pull.watcher_user_ids
    if watcher_user_ids and watcher_user_ids.length > 0
      watcher_user_ids.each {|id|
        pull.add_watcher(User.find(id.to_i))
      }
    end
  end

end