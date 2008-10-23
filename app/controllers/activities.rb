class Activities < Application
  RECENT_ACTIVITIES_NUM = 3
    
  before :login_required
  before :load_projects,              :only => [:new, :edit, :create]
  before :load_all_users,             :only => [:new, :edit, :create] # currently it needs to be named load_all_users 
                                                                      # instead of just load_users, because of bug 
                                                                      # (or design fault) in merb (1.0rc2) which confuses  
                                                                      # load_users with load_user
  before :load_user,                  :only => [:calendar] 
  before :check_calendar_viewability, :only => [:calendar]
  
  def index
    @search_criteria = SearchCriteria.new(params[:search_criteria])
    @activities = @search_criteria.activities
    render
  end
  
  def filter
    @search_criteria = SearchCriteria.new(params[:search_criteria])
    @activities = @search_criteria.activities
    render :index, :layout => false
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
    date = if params.has_key?("year") && params.has_key?("month")
             { :year => params[:year], :month => params[:month] }
           else
             :this_month
           end
    @activities = begin
                    @user.activities.for(date)
                  rescue ArgumentError
                    raise BadRequest
                  end
    @activities_by_date = @activities.group_by { |a| a.date }
    render
  end
  
  protected
  
  def check_calendar_viewability
    raise Forbidden unless @user.calendar_viewable?(current_user)
  end
  
  def load_user
    raise NotFound unless @user = User.get(params[:user_id])
  end
  
  def load_projects
    @recent_projects = current_user.projects.active.sort_by { |p| p.activities.recent(1).first.created_at }
    @recent_projects = @recent_projects.reverse[0...RECENT_ACTIVITIES_NUM]
    # .all(:order => ["activities.created_at DESC"], :limit => RECENT_ACTIVITIES_NUM)
    @other_projects = Project.active - @recent_projects
  end
  
  def load_all_users
    @users = Employee.active.all(:order => [:name.asc]) if current_user.is_admin?
  end
end # Activities
