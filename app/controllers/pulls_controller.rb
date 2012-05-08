class PullsController < ApplicationController
  unloadable
  
  #menu_item :pull_requests
  before_filter :find_project
  before_filter :find_repository

  def index
    @pulls = Pull.find(:all)
  end
  
  def show
    @pull = Pull.find(params[:id])
    @base_branch = @pull.base_branch
    @head_branch = @pull.head_branch
    show_diff(@base_branch, @head_branch)
  end

  def new
    @base_branch = params[:base_branch]
    @head_branch = params[:head_branch]

    @repositories = @project.repositories
    @repos = @repositories.sort.collect {|repo| repo.name}

    # diff
    if params[:head_branch].present? and params[:base_branch].present?
      show_diff(@base_branch, @head_branch)
    end
  end

  def create
    @pull = @project.pulls.build(params[:pull])
    @pull.repository = @repository
    @pull.user = User.current
    if @pull.save
      flash[:notice] = l(:notice_pull_created)
      redirect_to :action => 'show', :project_id => @project.name, :repository_id => @pull.repository.name, :id => @pull.id
    else
      render(params[:fork].blank? ? :new : :edit)
    end
  end

  def edit
  end
  
  def update
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
  
  
  def show_diff(base_branch, head_branch)
      @path = ''
      @rev = base_branch
      @rev_to = head_branch

      @revisions = @repository.revisions('', @rev, @rev_to)

      @diff_type = 'inline'
      @cache_key = "repositories/diff/#{@repository.id}/" +
                      Digest::MD5.hexdigest("#{@path}-#{@revisions}-#{@diff_type}-#{current_language}")
      unless read_fragment(@cache_key)
        @diff = []
        @revisions.each do |r|
          @diff.concat(@repository.diff(@path, r.scmid, nil))
        end
      end
  end
end
