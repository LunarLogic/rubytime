class Sessions < Application
  before :login_required
  
  def create
    if user = User.authenticate(params[:login], params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Successfully loged in."
      redirect "/"
    else
      flash[:error] = "Bad login or password."
      redirect url(:login)
    end
  end
  
  def index
    if current_user.instance_of? User
      redirect url(:new_activity)
    elsif current_user.instance_of? ClientUser
      redirect url(:new_activity)
    elsif current_user.instance_of? Admin
      redirect url(:activities)
    else
      raise Forbidden
    end
  end
  
  def new
    render
  end
  
  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out."
    redirect url(:login)
  end
end