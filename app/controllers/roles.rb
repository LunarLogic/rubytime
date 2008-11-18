class Roles < Application
  before :ensure_admin
  before :load_roles, :only => [:index, :create]
  
  def index
    @role = Role.new
    render
  end
  
  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect url(:roles)
    else
      render :index
    end
  end
  
  def destroy
    raise NotFound unless @role = Role.get(params[:id])
    if @role.destroy
      render_success
    else
      render_failure "Users with this role exist. Couldn't delete."
    end
  end

  protected
  def load_roles
    @roles = Role.all(:order => [:name])
  end
end # Roles
