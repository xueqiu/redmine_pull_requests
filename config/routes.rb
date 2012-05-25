ActionController::Routing::Routes.draw do |map|
  
  map.with_options :controller => 'pulls' do |pulls|
    pulls.with_options :conditions => {:method => :get} do |pull_view|
      pull_view.connect 'projects/:project_id/pulls', 
                        :action => 'index'
      pull_view.connect 'projects/:project_id/pulls/status/:status', 
                        :action => 'index'
      pull_view.connect 'projects/:project_id/pull/:id', 
                        :action => 'show'
      pull_view.connect 'projects/:project_id/pull/:id/edit', 
                        :action => 'edit'
      pull_view.connect 'projects/:project_id/pull/:id', 
                        :action => 'update', :conditions => {:method => :put}
      pull_view.connect 'projects/:project_id/pull/:id/merge', 
                        :action => 'merge', :conditions => {:method => :put}
      pull_view.connect 'projects/:project_id/pull/:id/close', 
                        :action => 'close', :conditions => {:method => :put}
      pull_view.connect 'projects/:project_id/pull/:id/cancel', 
                        :action => 'cancel', :conditions => {:method => :put}                        
    end
  end
  
  map.resources :pulls, :path_prefix => '/projects/:project_id'

end