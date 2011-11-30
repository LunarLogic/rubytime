class ActivityTypes < Application
  
  before :ensure_admin, :exclude => [:available, :for_projects]
  before :ensure_can_see_available, :only => [:available]

  def index
    @activity_types = ActivityType.roots
    @new_activity_type = ActivityType.new
    display @activity_types
  end

  def show
    @activity_type = ActivityType.get(params[:id]) or raise NotFound

    if @activity_type.parent
      redirect resource(@activity_type.parent)
    else
      @new_activity_type = ActivityType.new(:parent => @activity_type)
      display @activity_type
    end
  end

  def edit
    only_provides :html
    @activity_type = ActivityType.get(params[:id]) or raise NotFound
    display @activity_type
  end

  def create
    @new_activity_type = ActivityType.new(params[:activity_type])
    if @new_activity_type.save
      if @new_activity_type.parent
        redirect resource(@new_activity_type.parent), :message => {:notice => "Sub-activity type was successfully created"}
      else
        redirect resource(:activity_types), :message => {:notice => "Activity type was successfully created"}
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
    @activity_type = ActivityType.get(params[:id]) or raise NotFound
    if @activity_type.update(params[:activity_type])
      @activity_type.move(:to => new_position) if new_position && new_position != @activity_type.position
      if request.xhr?
        render_success
      elsif @activity_type.parent
        redirect resource(@activity_type.parent), :message => {:notice => "Sub-activity type was successfully updated"}
      else
        redirect resource(:activity_types), :message => {:notice => "Activity type was successfully updated"}
      end
    else
      @old_name = @activity_type.original_attributes[ActivityType.properties[:name]]
      display @activity_type, :edit
    end
  end

  def destroy
    @activity_type = ActivityType.get(params[:id]) or raise NotFound
    if @activity_type.destroy
      redirect resource(@activity_type.parent ? @activity_type.parent : :activity_types)
    else
      raise InternalServerError
    end
  end

  def available
    provides :json
    
    project = Project.get(params[:project_id]) or raise NotFound
    activity_type = ActivityType.get(params[:activity_type_id])
    
    @activity_types = project.activity_types.all(:parent_id => activity_type ? activity_type.id : nil)
    
    display @activity_types
  end
  
  def for_projects
    only_provides :json
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    display :options => @search_criteria.all_activity_types.map { |at| { :id => at.id, :name => at.name } }, 
      :projects_with_activities_without_types_selected => @search_criteria.found_projects_with_activities_without_types?
  end
  
  def number_of_columns
    params[:action] == "edit" || params[:action] == "update" || params[:action] == "index" && current_user.is_client_user? ? 1 : super
  end
  
  protected
  
  def ensure_can_see_available
    raise Forbidden unless current_user.is_admin? || current_user.is_employee? || (current_user.is_client_user? and current_user.client.projects.get(params[:project_id]))
  end

end # ActivityTypes
