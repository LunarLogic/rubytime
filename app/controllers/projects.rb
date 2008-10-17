class Projects < Application

  before :login_required
  before :admin_required
  before :load_project, :only => [:edit, :update, :destroy, :show]
  before :load_clients, :only => [:new, :create, :edit, :update]
  
  def index
    @projects = Project.all(:order => [:name])
    render
  end
  
  def new
    @project = Project.new
    render :edit
  end
  
  def show
    render
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect url(:projects)
    else
      render :edit
    end
  end
  
  def edit
    render
  end
  
  def update
    if @project.update_attributes(params[:project]) || !@project.dirty? 
      redirect url(:projects)
    else
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
  
  protected

  def load_project
    raise NotFound unless @project = Project.get(params[:id])
  end
  
  def load_clients
    @clients = Client.active
  end
  
end # Projects
