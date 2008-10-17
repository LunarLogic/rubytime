class Activities < Application
  RECENT_ACTIVITIES_NUM = 3

  before :login_required
  before :load_projects, :only => [:new, :edit, :create]

  def index
    render
  end
  
  def new
    @activity = Activity.new(:date => Date.today)
    render :layout => false
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    if @activity.save
      render "", :layout => false, :status => 201
    else
      render :new, :layout => false
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
    @recent_projects = current_user.projects.active.sort_by { |p| p.activities.recent(1).first.created_at }
    @recent_projects = @recent_projects.reverse[0...RECENT_ACTIVITIES_NUM]
    # .all(:order => ["activities.created_at DESC"], :limit => RECENT_ACTIVITIES_NUM)
    @other_projects = Project.active - @recent_projects
  end
  
end # Activities
