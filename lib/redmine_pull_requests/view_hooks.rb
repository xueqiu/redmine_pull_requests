module RedminePullRequests
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_projects_index_activity_menu,
      :partial => 'hooks/redmine_all_pulls_link'
  end
end
