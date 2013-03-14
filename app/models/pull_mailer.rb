class PullMailer < Mailer
  
  def pull_add(pull)
    @user = pull.user

    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user

    message_id pull
    recipients = find_recipients(pull.repository)
    subject = "[#{pull.project.name} - Pull request ##{pull.id}] #{pull.title}"
    @pull = pull
    @pull_url = url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    
    mail :to => recipients, :subject => subject
  end
  
  def pull_close(item)
    pull = item.pull
    @user = item.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients = find_recipients(pull.repository)
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
    recipients = find_recipients(pull.repository)
    subject = "[#{pull.project.name} - Pull request ##{pull.id}] (#{item.item_type.camelize}) #{pull.title}"
    @pull = pull
    @item = item
    @pull_url = url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    mail :to => recipients, :subject => subject
  end

  private
  def find_recipients(repo)
    default = Setting.plugin_redmine_pull_requests['default_sent_to_email']
    # get active user only
    recipients = User.find_all_by_id_and_status(repo.committers.collect(&:last).collect(&:to_i), 1).collect(&:mail)
    recipients += [default] if !recipients.include?(default)
    recipients
  end

end