class Users < Application
  # provides :xml, :yaml, :js
  
  before :ensure_admin, :only => [:new, :create, :destroy, :index]
  before :load_user, :only => [:edit, :update, :show, :destroy] 
  before :load_users, :only => [:index, :create]
  before :load_clients_and_roles, :only => [:index, :create]
  before :check_authorization, :only => [:edit, :update, :show]

  def index
    @user = User.new
    display @users
  end

  def show
    display @user
  end

  def edit
    only_provides :html
    render
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect url(:user, @user)
    else
      render :index
    end
  end

  def update
    #@user.inspect # fix for dm's validation bug
    if @user.update_attributes(params[:user]) || !@user.dirty?
      redirect url(:user, @user)
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      render_success
    else
      render_failure "Couldn't delete user which has activities"
    end
  end
  
  # Returns all users matching current selected roles
  def with_roles
    raise Forbidden unless current_user.is_admin? || current_user.is_client_user?
    only_provides :json
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    display @search_criteria.all_users.map { |u| { :id => u.id, :name => u.name } }
  end
  
protected

  def load_users
    @users = User.all
  end
  
  def load_user
    raise NotFound unless @user = User.get(params[:id]) 
  end
  
  def load_clients_and_roles
    @clients = Client.active.all(:order => [:name])
    @roles = Role.all(:order => [:name])
  end

  def check_authorization
    raise Forbidden unless @user.editable_by?(current_user)
  end
end # Users
