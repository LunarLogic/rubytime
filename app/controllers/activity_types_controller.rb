class ActivityTypesController < ApplicationController
  
  before_filter :ensure_admin, :except => [:available, :for_projects]
  before_filter :ensure_can_see_available, :only => [:available]
  before_filter :find_activity_type, :only => [:show, :edit, :update, :destroy]

  respond_to :json, :html

  def index
    @activity_types = ActivityType.roots
    @new_activity_type = ActivityType.new
    respond_with @activity_types
  end

  def show
    @new_activity_type = ActivityType.new(:parent => @activity_type)
    respond_with @activity_type
  end

  def edit
    respond_to do |format|
      format.html { render :edit }
    end
  end

  def create
    @new_activity_type = ActivityType.new(params[:activity_type])
    if @new_activity_type.save
      if @new_activity_type.parent
        redirect_to activity_type_path(@new_activity_type.parent), :notice => "Sub-activity type was successfully created"
      else
        redirect_to activity_types_path, :notice => "Activity type was successfully created"
      end
    else
      if @new_activity_type.parent
        @activity_type = @new_activity_type.parent
        render :show
      else
        @activity_types = ActivityType.roots
        render :index
      end
    end
  end

  def update
     new_position = params[:activity_type].delete(:position)

    if @activity_type.update(params[:activity_type])
      @activity_type.move(:to => new_position) unless new_position == @activity_type.position
      if request.xhr?
        render_success
      elsif @activity_type.parent
        redirect_to activity_type_path(@activity_type.parent), :notice => "Sub-activity type was successfully updated"
      else
        redirect_to activity_types_path, :notice => "Activity type was successfully updated"
      end
    else
      @old_name = @activity_type.original_attributes[ActivityType.properties[:name]]
      respond_with @activity_type
    end
  end

  def destroy
    if @activity_type.destroy
      redirect_to @activity_type.parent ? activity_type_path(@activity_type.parent) : activity_types_path
    else
      raise InternalServerError
    end
  end

  def available
    not_found and return unless project = Project.get(params[:project_id])
    activity_type = ActivityType.get(params[:activity_type_id])
    
    @activity_types = project.activity_types.all(:parent_id => activity_type ? activity_type.id : nil)

    respond_to do |format|
      format.json { render :json => @activity_types }
    end
  end
  
  def for_projects
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    render :json => { :options => @search_criteria.all_activity_types.map { |at| { :id => at.id, :name => at.name } }, 
      :projects_with_activities_without_types_selected => @search_criteria.found_projects_with_activities_without_types? }
  end
  
  def number_of_columns
    params[:action] == "edit" || params[:action] == "update" || params[:action] == "index" && current_user.is_client_user? ? 1 : super
  end
  
  protected
  
  def ensure_can_see_available    
    forbidden and return unless current_user.is_admin? || current_user.is_employee? || (current_user.is_client_user? and current_user.client.projects.get(params[:project_id]))
  end

  def find_activity_type
    not_found and return unless @activity_type = ActivityType.get(params[:id])
  end

end # ActivityTypes
