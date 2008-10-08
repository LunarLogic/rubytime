class Projects < Application

  before :login_required
  before :admin_required
  before :get_project, :only => [:edit, :update, :destroy]
  
  def index
    @projects = Project.all(:order => [:name])
    render
  end
  
  def new
    @clients = Client.active
    @project = Project.new
    render :edit
  end
  
  def create
    @clients = Client.active
    @project = Project.new(params[:project])
    if @project.save
      redirect url(:project, @project)
    else
      render :edit
    end
  end
  
  def edit
    @clients = Client.active
    render
  end
  
  def update
    @project.update_attributes(params[:project])
    if @project.save
      redirect url(:project, @project)
    else
      render :edit
    end
  end
  
  def destroy
    @project.destroy
    redirect url(:projects)
  end
  
  protected
  def get_project
    @project = Project.get(params[:id])
    raise NotFound unless @project
  end
  
end # Projects
