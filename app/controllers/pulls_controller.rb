class PullsController < ApplicationController
  unloadable
  
  menu_item :pull_requests
  before_filter :find_project

  def index
    @pulls = Pull.find(:all)
  end
  
  def show
  end

  def new
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
