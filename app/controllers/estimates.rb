class Estimates < Application

  before :ensure_admin
  before :load_projects, :only => [:index]
  before :load_project, :only => [:index, :update_all]
  
  def index
    if @project
      display @project.estimates
    else
      render :projects
    end
  end
  
  def update_all
    @project or raise NotFound
    
    if @project.update_estimates(params[:project][:activity_types])
      redirect resource(:estimates), :message => { :notice => "Estimates have been updated" }
    else
      render :index
    end
  end
  
protected
  
  def load_projects
    @projects = Project.visible_for(current_user).all(:order => [:name])
  end

  def load_project
    @project = Project.get(params[:project_id])
  end
  
  def number_of_columns
    1
  end

end # Estimates
