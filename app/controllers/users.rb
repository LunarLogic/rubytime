class Users < Application
  # provides :xml, :yaml, :js
  
  before :login_required
  before :admin_required, :only => [:new, :create, :destroy, :index]
  before :get_user, :only => [:edit, :update, :show, :destroy] 
  before :check_authorization, :only => [:edit, :update, :show]

  def index
    @users = User.all
    display @users
  end

  def show
    display @user
  end

  def new
    only_provides :html
    @user = User.new
    render
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
      render :new
    end
  end

  def update
    @user.inspect # fix for dm's validation bug
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
  
  def with_roles
    only_provides :json
    @search_criteria = SearchCriteria.new(params[:search_criteria])
    display @search_criteria.users.map { |u| { :id => u.id, :name => u.name } }
  end
  
  protected
  
  def get_user
    raise NotFound unless @user = User.get(params[:id]) 
  end

  def check_authorization
    raise Forbidden unless @user.editable_by?(current_user)
  end
end # Users
