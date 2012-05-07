class PullsController < ApplicationController
  unloadable
  
  #menu_item :pull_requests
  before_filter :find_project

  def index
    @pulls = Pull.find(:all)
  end
  
  def show
  end

  def new
    @head_branch = params[:head_branch]
    @base_branch = params[:base_branch]

    @project = Project.find(params[:project_id])
    @repositories = @project.repositories
    @repos = @repositories.sort.collect {|repo| repo.name}
    if params[:repository_id].present?
      @repository = @project.repositories.find_by_identifier_param(params[:repository_id])
    else
      @repository = @project.repository
    end
    
    # diff
    if params[:head_branch].present? and params[:base_branch].present?
#      latest_base_changesets = @repository.latest_changesets('', @base_branch, 1)
#      latest_base_changeset = latest_base_changesets.first.scmid if latest_base_changesets.length > 0
      
      # commits
#      @revision = @repository.branch_ancestor(@base_branch, @head_branch)
#      fl = @revision[0]
#      if(fl != '+' and fl != '-')
        @path = ''
 #       @rev = @revision
        @rev = @base_branch
        @rev_to = @head_branch

        @revisions = @repository.revisions('', @rev, @rev_to)

        @diff_type = 'inline'
        @cache_key = "repositories/diff/#{@repository.id}/" +
                        Digest::MD5.hexdigest("#{@path}-#{@rev}-#{@rev_to}-#{@diff_type}-#{current_language}")
        unless read_fragment(@cache_key)
          #@diff = @repository.diff(@path, @rev_to, @rev)
          
          @diff = []
          @revisions.each do |r|
            @diff.concat(@repository.diff(@path, r.scmid, nil))
          end
        end

        #@changeset = @repository.find_changeset_by_name(@rev)
        #@changeset_to = @rev_to ? @repository.find_changeset_by_name(@rev_to) : nil
        #@diff_format_revisions = @repository.diff_format_revisions(@changeset, @changeset_to) 
#      end
    end      
  end

  def create
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
end
