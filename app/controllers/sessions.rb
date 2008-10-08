class Sessions < Application
  before :login_required, :only => [:index, :destroy]
  
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
    case current_user
    when Admin
      redirect url(:activities)
    when ClientUser
      redirect url(:activities)
    when Employee
      redirect url(:new_activity)
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