ActionController::Routing::Routes.draw do |map|
  #map.connect 'projects/:id/pulls', :controller => 'pulls',
  #            :action => 'index', :conditions => {:method => :get}
  map.resources :pulls, :path_prefix => '/projects/:project_id'
end