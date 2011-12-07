class ProjectsController < ApplicationController
  respond_to :json, :html

  before_filter :ensure_admin, :except => [:for_clients, :index]
  before_filter :ensure_can_list_projects, :only => [:index]
  before_filter :load_project, :only => [:edit, :update, :destroy, :show, :set_default_activity_type]
  before_filter :load_projects, :only => [:index, :create]
  before_filter :load_clients, :only => [:index, :new, :create]
  
  def index
    @project = Project.new :client => Client.get(params[:client_id])
    if request.format.json?
      # for JSON API, add flag 'has_activities' which says if that project has any activities by current user
      @projects_with_activities = Project.with_activities_for(current_user)
      @projects.each do |p|
        p.has_activities = @projects_with_activities.any? { |pwa| pwa.id == p.id }
      end

      if params[:include_activity_types]
        respond_with @projects, :methods => [:has_activities, :available_activity_types]
      else
        respond_with @projects, :methods => [:has_activities]
      end
    else
      respond_with @projects
    end
  end
  
  def show
    @expand_hourly_rates = (params[:expand_hourly_rates] == 'yes')
    unless @project.activity_types.empty?
      @activities_without_types = @project.activities.all(:activity_type_id => nil)
    end
    render
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to project_path(@project, :expand_hourly_rates => 'yes')
    else
      render :index
    end
  end

  def edit
    @clients = Client.all
    render
  end
  
  def update
    if @project.update(params[:project]) || !@project.dirty?
      redirect_to project_path(@project)
    else
      @clients = Client.all
      render :edit
    end
  end
  
  def destroy
    if @project.destroy
      render_success
    else
      render_failure "This project has activities. Couldn't delete."
    end
  end
  
  def set_default_activity_type
    @activity_type = ActivityType.get!(params[:activity_type_id])

    @activities = @project.activities.all(:activity_type_id => nil)
    @activities.each do |a|
      a.activity_type = @activity_type
      a.save
    end

    redirect_to project_path(@project)
  end
  
  # Returns all projects matching current selected clients
  def for_clients
    forbidden and return if current_user.is_client_user?
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)

    render :json => {:options => 
      @search_criteria.all_projects.map { |p| { :id => p.id, :name => p.name } } }
  end

protected
  def ensure_can_list_projects
    forbidden and return unless current_user.is_admin? || current_user.is_client_user? || request.format.json?
  end

  def load_project
    @project = Project.get!(params[:id])
  end
  
  def load_projects
    @projects = Project.visible_for(current_user).all(:order => [:name])
  end
  
  def load_clients
    @clients = Client.active
  end
  
  
  def number_of_columns
    params[:action] == "show" || params[:action] == "edit" || params[:action] == "index" && current_user.is_client_user? ? 1 : super
  end
end # Projects
