class Activities < Application

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
    @recent_projects = Project.all
    @other_projects = Project.all - @recent_projects
  end
  
end # Activities
