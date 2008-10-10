class Activities < Application
  RECENT_ACTIVITIES_LIMIT = 3

  before :login_required
  before :admin_required, :only => [:index]
  before :load_projects, :only => [:new, :edit, :create]

  def index
    render
  end
  
  def new
    @activity = Activity.new(:date => Date.today)
    render
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    if @activity.save
      "ok!"
    else
      render :new
    end
  end
  
  def edit
  end

  def update
  end

  def destroy
  end
  
  protected
  def load_projects
    @recent_projects = current_user.projects.active.all(:order => [:created_at.desc], :limit => RECENT_ACTIVITIES_LIMIT)
    @other_projects = Project.active - @recent_projects
  end
  
end # Activities
