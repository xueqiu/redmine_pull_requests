class PullMailer < Mailer
  
  def pull_add(pull)
    @user = pull.user

    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients [Setting.plugin_redmine_pull_requests['default_sent_to_email']]
    subject "[#{pull.project.name} - Pull request ##{pull.id}] #{pull.title}"
    body :pull => pull,
         :pull_url => url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    render_multipart('settings/pull_add', body)
  end
  
  def pull_close(pull)
    @user = pull.items.last.user
    
    redmine_headers 'Project' => pull.project.identifier,
                    'Pull-Request-Id' => pull.id,
                    'Pull-Request-Author' => pull.user
    message_id pull
    recipients [Setting.plugin_redmine_pull_requests['default_sent_to_email']]
    subject "[#{pull.project.name} - Pull request ##{pull.id}] (#{pull.status.camelize}) #{pull.title}"
    body :pull => pull,
         :pull_url => url_for(:controller => 'pulls', :action => 'show', :project_id => pull.project.identifier, :id => pull.id)
    render_multipart('settings/pull_close', body)
  end

end