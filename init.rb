require 'redmine'
require 'dispatcher'

require_dependency 'redmine_pull_requests/view_hooks'
require_dependency 'redmine_pull_requests/project_patch'
require_dependency 'redmine_pull_requests/repository_git_patch'

Dispatcher.to_prepare :redmine_pull_requests do
  require_dependency 'project'
  require_dependency 'repository'

  unless Project.included_modules.include? RedminePullRequests::ProjectPatch
    Project.send(:include, RedminePullRequests::ProjectPatch)
  end

  unless Repository.included_modules.include? RedminePullRequests::RepositoryPatch
    Repository.send(:include, RedminePullRequests::RepositoryPatch)
  end

  unless Repository::Git.included_modules.include? RedminePullRequests::RepositoryGitPatch
    Repository.send(:include, RedminePullRequests::RepositoryGitPatch)
  end
end

Redmine::Plugin.register :redmine_pull_requests do
  name 'Redmine Pull Requests plugin'
  author 'pawa'
  description 'github like pull requests for redmine'
  version '0.1'
  url 'http://github.com/pawa/redmine_pull_requests'
  author_url 'http://pawa.github.com'

  requires_redmine :version_or_higher => '1.4.0'

  project_module :pull_requests do
    permission :view_pull_requests,   :pulls => [:index, :show]
    permission :add_pull_requests,    :pulls => [:new, :create]
    permission :edit_pull_requests,   :pulls => [:edit, :update]
    permission :delete_pull_requests, :pulls => [:destroy]
  end
  
  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, 
       :caption => :label_pull_requests, :after => :label_wiki, :param => :project_id  
end
