class Projects < Application
  before :ensure_admin, :exclude => [:for_clients]
  before :load_project, :only => [:edit, :update, :destroy, :show]
  before :load_all_projects, :only => [:index, :create]
  before :load_clients, :only => [:index, :new, :create, :edit, :update]
  
  def index
    @project = Project.new
    render
  end
  
  def show
    render
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect resource(@project)
    else
      render :index
    end
  end
  
  def edit
    render
  end
  
  def update
    if @project.update_attributes(params[:project]) || !@project.dirty?
      redirect resource(@project)
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
  
  # Returns all projects matching current selected clients
  def for_clients
    raise Forbidden if current_user.is_client_user?
    only_provides :json
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    display @search_criteria.all_projects.map { |p| { :id => p.id, :name => p.name } }
  end

  protected

  def load_project
    @project = Project.get(params[:id]) or raise NotFound
  end
  
  def load_all_projects
    @projects = Project.all(:order => [:name])
  end
  
  def load_clients
    @clients = Client.active
  end
  
end # Projects
