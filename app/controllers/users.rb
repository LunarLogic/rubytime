class Users < Application
  # provides :xml, :yaml, :js

  def index
    @users = User.all
    display @users
  end

  def show
    @user = User.get(params[:id])
    raise NotFound unless @user
    display @user
  end

  def new
    only_provides :html
    @user = User.new
    render
  end

  def edit
    only_provides :html
    @user = User.get(params[:id])
    raise NotFound unless @user
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
    @user = User.get(params[:id])
    raise NotFound unless @user
    if @user.update_attributes(params[:user]) || !@user.dirty?
      redirect url(:user, @user)
    else
      raise BadRequest
    end
  end

  def destroy
    @user = User.get(params[:id])
    raise NotFound unless @user
    if @user.destroy
      redirect url(:user)
    else
      raise BadRequest
    end
  end

end # Users
