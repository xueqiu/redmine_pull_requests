ActionController::Routing::Routes.draw do |map|
  
  map.with_options :controller => 'pulls' do |pulls|
    pulls.with_options :conditions => {:method => :get} do |pull_view|
      pull_view.connect 'projects/:project_id/repository/:repository_id/pull/:id', 
                        :action => 'show'
    end
  end
  map.resources :pulls, :path_prefix => '/projects/:project_id'

end