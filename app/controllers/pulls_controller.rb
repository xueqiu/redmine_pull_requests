class PullsController < ApplicationController
  unloadable

  #menu_item :pull_requests
  before_filter :find_project
  before_filter :find_repository, :only => [:new, :edit, :create, :update]

  def index
    @status = params[:status].present? ? params[:status] : "open"
    
    @limit = per_page_option
    @pulls_count = @project.pulls.with_status(@status).count
    @pulls_pages = Paginator.new(self, @pulls_count, @limit, params[:page])
    @offset ||= @pulls_pages.current.offset
    
    @pulls = @project.pulls.find(:all, :conditions => ["status = ?", @status],
                                 :order => 'created_on DESC', :offset => @offset, :limit => @limit)
  end
  
  def show
    @pull = Pull.find(params[:id])
    @repository = @pull.repository
    @base_branch = @pull.base_branch
    @head_branch = @pull.head_branch
    
    if @pull.status == "open"
      find_diff(@repository, @base_branch, @head_branch)
      @merge_conflict = @repository.merge_conflict?(@base_branch, @head_branch)
    else
      items = @pull.items
      if items.length > 0
        diff_item = items.shift if items.first.item_type == 'diff'
        commits = []
        @statuses = []
        @comments = []
        items.each do |i| 
          if i.item_type == 'commit'
            commits << i.revision
          elsif i.item_type == 'comment'
            @comments << i
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
  end

  def new
    @base_branch = params[:base_branch]
    @head_branch = params[:head_branch]

    @repositories = @project.repositories

    # diff
    if @head_branch.present? and @base_branch.present?
      find_diff(@repository, @base_branch, @head_branch)
    end
  end

  def create
    @pull = @project.pulls.build(params[:pull])
    @pull.repository = @repository
    @pull.user = User.current
    
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

  def reviewed
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "closed")
      @pull.items.create(:item_type => "reviewed", :user_id => User.current.id)
      flash[:notice] = l(:notice_pull_closed)
    else
      flash[:error] = l(:notice_pull_close_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end

  def merge
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "closed")
      @pull.repository.merge(@pull.base_branch, @pull.head_branch)
      @pull.items.create(:item_type => "reviewed", :user_id => User.current.id)
      @pull.items.create(:item_type => "merged", :user_id => User.current.id)
      @pull.items.create(:item_type => "closed", :user_id => User.current.id)
      flash[:notice] = l(:notice_pull_closed)
    else
      flash[:error] = l(:notice_pull_close_failed)
    end
    redirect_to :action => 'show', :project_id => @project.identifier, :id => @pull.id
  end
  
  def close
    @pull = Pull.find(params[:id])
    if @pull.update_attributes(:status => "closed")
      @pull.items.create(:item_type => "reviewed", :user_id => User.current.id)
      @pull.items.create(:item_type => "closed", :user_id => User.current.id)
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
    if @revisions.size > 0
      @diff_type = 'inline'
      @cache_key = "repositories/diff/#{@repository.id}/" +
                   Digest::MD5.hexdigest("#{@path}-#{@revisions}-#{@diff_type}-#{current_language}")
      unless read_fragment(@cache_key)
        @diff = @repository.diff_with_merge_base(@path, @rev_to, @rev)
      end
    end
  end
  
  def save_items(pull)
    rev = params[:pull][:base_branch]
    rev_to = params[:pull][:head_branch]    
    revisions = @repository.revisions('', rev, rev_to)
    diff = @repository.diff_with_merge_base('', rev_to, rev)
    
    if(revisions.length > 0) 
      if diff.present?
        PullItem.create(:pull_id => pull.id, :item_type => "diff", :content => diff.join('$$$$$'))
      end
      
      revisions.each do |r|
        PullItem.create(:pull_id => pull.id, :item_type => "commit", 
                        :revision => r.scmid, :user_id => r.user_id)
      end
    end
  end
end
