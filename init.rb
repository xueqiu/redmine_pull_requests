require 'redmine'

require_dependency 'redmine_pull_requests/view_hooks'
require_dependency 'redmine_pull_requests/project_patch'
require_dependency 'redmine_pull_requests/repository_patch'
require_dependency 'redmine_pull_requests/git_adapter_patch'


Redmine::Activity.map do |activity|
  activity.register :pulls
end

Redmine::Search.map do |search|
  search.register :pulls
end

ActionDispatch::Reloader.to_prepare do
  require_dependency 'project'
  require_dependency 'repository'
  require_dependency 'redmine/scm/adapters/git_adapter'

  unless Project.included_modules.include? RedminePullRequests::ProjectPatch
    Project.send(:include, RedminePullRequests::ProjectPatch)
  end

  unless Repository.included_modules.include? RedminePullRequests::RepositoryPatch
    Repository.send(:include, RedminePullRequests::RepositoryPatch)
  end

  unless Redmine::Scm::Adapters::GitAdapter.included_modules.include? RedminePullRequests::GitAdapterPatch
    Redmine::Scm::Adapters::GitAdapter.send(:include, RedminePullRequests::GitAdapterPatch)
  end
  
  ActiveRecord::Base.observers << :pull_observer
  ActiveRecord::Base.observers << :pull_item_observer
end

Redmine::Plugin.register :redmine_pull_requests do
  name 'Redmine Pull Requests plugin'
  author 'Stone Wang'
  description 'Github like pull requests plugin for redmine'
  version '0.1'
  url 'http://github.com/xueqiu/redmine_pull_requests'
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
       
  settings(:default => { 'default_sent_to_email' => 'admin@example.org' }, :partial => 'settings/pull_requests_settings')
end








