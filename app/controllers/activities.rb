class Activities < Application

  before :login_required
  before :admin_required, :only => [:index]
  before :get_projects, :only => [:new, :edit, :create]

  def index
    render
  end
  
  def new
    @activity = Activity.new(:date => Date.today)
    render
  end
  
  def create
    p params[:activity]
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
  def get_projects
    @projects = Project.all
  end
  
end # Activities
