require 'redmine'

require_dependency 'redmine_pull_requests/view_hooks'

Redmine::Plugin.register :redmine_pull_requests do
  name 'Redmine Pull Requests plugin'
  author 'pawa'
  description 'github like pull requests for redmine'
  version '0.0.1'
  url 'http://github.com/pawa/redmine_pull_requests'
  author_url 'http://pawa.github.com'

  requires_redmine :version_or_higher => '1.4.0'

  project_module :pull_requests do
    permission :view_pull_requests,   :pulls => [:index, :show]
    permission :add_pull_requests,    :pulls => [:new, :create]
    permission :edit_pull_requests,   :pastes => [:edit, :update]
    permission :delete_pull_requests, :pastes => [:destroy]
  end
  
  menu :project_menu, :pull_requests, { :controller => 'pulls', :action => 'index' }, 
       :caption => :label_all_pull_requests, :after => :label_wiki, :param => :project_id  
end
