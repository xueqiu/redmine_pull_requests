module PullsHelper
  
  def link_to_all_pulls
    link_to l(:label_pull_requests_view),
      { :controller => "pulls", :action => "index", :project_id => @project },
      :class => "icon icon-multiple"
  end

  def link_to_new_pull
    link_to_if_authorized l(:label_pull_request_new),
      { :controller => "pulls", :action => "new", :project_id => @project },
      :class => "icon icon-add"
  end

  def format_revision(revision)
    if revision.respond_to? :format_identifier
      revision.format_identifier
    else
      revision.to_s
    end
  end

  def truncate_at_line_break(text, length = 255)
    if text
      text.gsub(%r{^(.{#{length}}[^\n]*)\n.+$}m, '\\1...')
    end
  end

  def pull_watchers_checkboxes(object, users, checked=nil)
    users.map do |user|
      c = false
      tag = check_box_tag 'pull[watcher_user_ids][]', user.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(user)}".html_safe,
                  :id => "pull_watcher_user_ids_#{user.id}",
                  :class => "floating"
    end.join.html_safe
  end

    
end
