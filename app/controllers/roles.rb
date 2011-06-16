class Roles < Application
  before :ensure_admin
  before :load_roles, :only => [:index, :create]
  
  def index
    provides :json
    @role = Role.new
    display @roles
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect url(:roles)
    else
      render :index
    end
  end
  
  def edit
    @role = Role.get(params[:id]) or raise NotFound
    render
  end
  
  def update
    @role = Role.get(params[:id]) or raise NotFound
    if @role.update(params[:role]) || !@role.dirty?
      redirect resource(:roles)
    else
      render :edit
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
  
  def number_of_columns
    params[:action] == "edit" ? 1 : super
  end
end # Roles
