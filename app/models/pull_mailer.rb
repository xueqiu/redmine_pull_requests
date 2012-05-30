class PullMailer < Mailer
  
  def pull_add(pull)
    @user = pull.user

    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients find_recipients(pull.repository)
    subject "[#{pull.project.name} - Pull request ##{pull.id}] #{pull.title}"
    body :pull => pull,
         :pull_url => url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    render_multipart('settings/pull_add', body)
  end
  
  def pull_close(item)
    pull = item.pull
    @user = item.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients find_recipients(pull.repository)
    subject "[#{pull.project.name} - Pull request ##{pull.id}] (#{item.item_type.camelize}) #{pull.title}"
    body :pull => pull, :item => item,
         :pull_url => url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    render_multipart('settings/pull_close', body)
  end

  def pull_comment(item)
    pull = item.pull
    @user = item.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients  find_recipients(pull.repository)
    subject "[#{pull.project.name} - Pull request ##{pull.id}] (#{item.item_type.camelize}) #{pull.title}"
    body :pull => pull, :item => item,
         :pull_url => url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    render_multipart('settings/pull_comment', body)
  end  

  private
  def find_recipients(repo)
    default = Setting.plugin_redmine_pull_requests['default_sent_to_email']
    recipients = User.find_all_by_id(repo.committers.collect(&:last).collect(&:to_i)).collect(&:mail)
    recipients += [default] if !recipients.include?(default)
    recipients
  end

end