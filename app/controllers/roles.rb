class Roles < Application

  before :login_required
  before :admin_required
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
  
  def update
    # if @role.update_attributes(params[:role]) || !@role.dirty? 
    #   redirect url(:roles)
    # else
    #   render :edit
    # end
  end
  
  def destroy
    # @role.destroy
    ""
  end

  protected
  def load_roles
    @roles = Role.all(:order => [:name])
  end
end # Roles
