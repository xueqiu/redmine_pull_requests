class PullsController < ApplicationController
  unloadable

  helper :watchers
  include WatchersHelper

  #menu_item :pull_requests
  before_filter :find_project
  before_filter :find_repository, :only => [:new, :edit, :create, :update]

  def index
    status = params[:status].present? ? params[:status] : "open"
    
    @limit = per_page_option
    @pulls_count = @project.pulls.with_status(status).count
    @pulls_pages = Paginator.new(self, @pulls_count, @limit, params[:page])
    @offset ||= @pulls_pages.current.offset
    
    @pulls = @project.pulls.find(:all, :conditions => ["status = ?", status],
                                 :order => 'created_on DESC', :offset => @offset, :limit => @limit)
  end
  
  def show
    @pull = Pull.find(params[:id])
    @repository = @pull.repository
    @base_branch = @pull.base_branch
    @head_branch = @pull.head_branch
    
    # verify branch exist or not
    if @pull.status == "open"
      unless @repository.cat('', @base_branch)
        flash[:error] = l(:notice_pull_branch_not_exists, :branch => @base_branch)
        @button_disable = true
        @button_cancel_disable = false
      end

      unless @repository.cat('', @head_branch)
        flash[:error] = l(:notice_pull_branch_not_exists, :branch => @head_branch)
        @button_disable = true
        @button_cancel_disable = false
      end
    else
      @button_disable = true
      @button_cancel_disable = true
    end
    # verify branch exist or not

    # verify current user is not sender
    if User.current.id == @pull.user_id
      @button_disable = true
    end
    # verify current user is not sender

    # verify if reviewed
    unless @pull.reviewed?
      @button_merge_disable = true
      @button_close_disable = true
    end
    # verify if reviewed
    
    find_diff_type

    if @pull.status == "open"
      find_diff(@repository, @base_branch, @head_branch)
      
      # if there are new commits, save commits and update diff
      rev_count = @revisions.length
      item_count = @pull.items.count(:conditions => "item_type = 'commit'")
      if rev_count > item_count 
        if @diff.present?
          diff_item = @pull.items.first
          diff_item.update_attributes(:content => @diff.join('$$$$$')) if diff_item and diff_item.item_type == 'diff'
        end
        
        PullItem.delete_all("pull_id = #{@pull.id} and item_type = 'file'")
        @files.each do |f|
          PullItem.create(:pull_id => @pull.id, :item_type => "file", :content => f) 
        end
        
        revs = @revisions[item_count, rev_count-item_count]
        revs.each do |r|
          PullItem.create(:pull_id => @pull.id, :item_type => "commit", 
                          :revision => r.scmid, :user_id => r.user_id)
        end        
      end
      
      @merge_conflict = @repository.merge_conflict?(@base_branch, @head_branch)
    end
    
    items = @pull.items(true)
    if items.length > 0
      diff_item = items.shift if items.first.item_type == 'diff'
      @statuses = []
      @comments = []
      @files = []
      commits = []
      items.each do |i| 
        if i.item_type == 'commit'
          commits << i.revision
        elsif i.item_type == 'file'
          @files << i.content
        elsif i.item_type == 'comment'
          @statuses << i
        else
          @statuses << i
        end
      end
      @revisions = Changeset.find(:all, :conditions => ["scmid IN (?)",commits], :order => 'committed_on')
      @cache_key = "repositories/diff/#{@repository.id}/" +
                   Digest::MD5.hexdigest("#{@path}-#{@revisions}-#{@diff_type}-#{current_language}")
      unless read_fragment(@cache_key)        
        @diff = (diff_item.present? and diff_item.item_type == 'diff') ? diff_item.content.split('$$$$$') : ""
      end
    end
  
  end

  def new
    @base_branch = params[:base_branch]
    @head_branch = params[:head_branch]
    find_diff_type

    @pull = @project.pulls.build
    @repositories = @project.repositories

    @available_watchers = @project.users.sort

    # diff
    if @head_branch.present? and @base_branch.present?
      find_diff(@repository, @base_branch, @head_branch)
    end
  end

  def create
    @pull = @project.pulls.build(params[:pull])
    @pull.repository = @repository
    @pull.user = User.current

    pull = Pull.where({base_branch: @pull.base_branch, head_branch: @pull.head_branch, status: 'open'}).first
    if pull
      flash[:notice] = l(:notice_pull_same_dont_need_to_recreat)
      redirect_to :action => 'show', :project_id => @project.identifier, :id => pull.id
      return
    end
    
    if @pull.save
      save_items(@pull)

      flash[:notice] = l(:notice_pull_created)
      redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
    else
      flash[:error] = l(:notice_pull_create_failed)
      render :new
    end
  end

  def edit
    @pull = Pull.find(params[:id])
    @repository = params[:repository_id].present? ? @repository : @pull.repository
    @base_branch = params[:base_branch].present? ? params[:base_branch] : @pull.base_branch
    @head_branch = params[:head_branch].present? ? params[:head_branch] : @pull.head_branch

    @repositories = @project.repositories
    #@repos = @repositories.sort.collect {|repo| repo.name}

    # diff
    if @head_branch.present? and @base_branch.present?
      find_diff(@repository, @base_branch, @head_branch)
    end    
  end
  
  def update
    @pull = Pull.find(params[:id])
    @pull.repository = @repository
    @pull.user = User.current
    if @pull.update_attributes(params[:pull])
      flash[:notice] = l(:notice_pull_updated)
      redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
    else
      flash[:error] = l(:notice_pull_update_failed)
      render :edit
    end
  end

  def comment
    @pull = Pull.find(params[:id])
    if @pull.comment(params[:comment])
      flash[:notice] = l(:notice_pull_commented)
    else
      flash[:error] = l(:notice_pull_comment_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end

  def review
    @pull = Pull.find(params[:id])
    if @pull.review_by(User.current.id)
      flash[:notice] = l(:notice_pull_reviewed)
    else
      flash[:error] = l(:notice_pull_review_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end

  def merge
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "closed")
      @pull.merge_by(User.current.id)      
      
      flash[:notice] = l(:notice_pull_closed)
    else
      flash[:error] = l(:notice_pull_close_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end
  
  def close
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "closed")
      @pull.close_by(User.current.id)
      
      flash[:notice] = l(:notice_pull_closed)
    else
      flash[:error] = l(:notice_pull_close_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end

  def cancel
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "canceled")
      @pull.items.create(:item_type => "canceled", :user_id => User.current.id)
      flash[:notice] = l(:notice_pull_canceled)
    else
      flash[:error] = l(:notice_pull_cancel_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end
  
  def destroy
  end
  
  private

  def find_project
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_repository
    if params[:repository_id].present?
      @repository = @project.repositories.find_by_identifier_param(params[:repository_id])
    else
      @repository = @project.repository
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_diff(repository, base_branch, head_branch)
    @path = ''
    @rev = base_branch
    @rev_to = head_branch

    @revisions = repository.revisions('', @rev, @rev_to)
    @files = repository.diff_files_with_merge_base(@path, @rev_to, @rev)
    if @revisions.size > 0
      @cache_key = "repositories/diff/#{@repository.id}/" +
                   Digest::MD5.hexdigest("#{@path}-#{@revisions}-#{@diff_type}-#{current_language}")
      unless read_fragment(@cache_key)
        @diff = @repository.diff_with_merge_base(@path, @rev_to, @rev)
      end
    end
  end

  def find_diff_type
    @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
    @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)

    # Save diff type as user preference
    if User.current.logged? && @diff_type != User.current.pref[:diff_type]
      User.current.pref[:diff_type] = @diff_type
      User.current.preference.save
    end
  end
  
  def save_items(pull)
    rev = params[:pull][:base_branch]
    rev_to = params[:pull][:head_branch]    
    revisions = @repository.revisions('', rev, rev_to)
    files = @repository.diff_files_with_merge_base('', rev_to, rev)
    diff = @repository.diff_with_merge_base('', rev_to, rev)
    
    if(revisions.length > 0) 
      if diff.present?
        PullItem.create(:pull_id => pull.id, :item_type => "diff", :content => diff.join('$$$$$'))
      end

      files.each do |f|
        PullItem.create(:pull_id => pull.id, :item_type => "file", :content => f)
      end
      
      revisions.each do |r|
        PullItem.create(:pull_id => pull.id, :item_type => "commit", 
                        :revision => r.scmid, :user_id => r.user_id)
      end
    end
  end

end
