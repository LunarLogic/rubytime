class Activities < Application
  RECENT_ACTIVITIES_NUM = 3

  before :login_required
  before :load_projects, :only => [:new, :edit, :create]
  before :load_users, :only => [:new, :edit, :create]

  def index
    @search_criteria = SearchCriteria.new(params[:search_criteria])
    @clients = @search_criteria.clients
    @projects = @search_criteria.projects
    @roles = @search_criteria.roles
    @users = @search_criteria.users
    @activities = @search_criteria.activities
    # p @search_criteria
    if request.xhr?
      partial :filter_form
    else
      render
    end
  end
  
  def new
    @activity = Activity.new(:date => Date.today, :user => current_user)
    render :layout => false
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user unless current_user.is_admin?
    if @activity.save
      render "", :status => 201, :layout => false 
    else
      render :new, :status => 200, :layout => false
    end
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end


  def calendar
    
  end
  
  protected
  
  def load_projects
    @recent_projects = current_user.projects.active.sort_by { |p| p.activities.recent(1).first.created_at }
    @recent_projects = @recent_projects.reverse[0...RECENT_ACTIVITIES_NUM]
    # .all(:order => ["activities.created_at DESC"], :limit => RECENT_ACTIVITIES_NUM)
    @other_projects = Project.active - @recent_projects
  end
  
  def load_users
    @users = Employee.active.all(:order => [:name.asc]) if current_user.is_admin?
  end
end # Activities
