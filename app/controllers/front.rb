class Front < Application

  before :login_required
  
  def index
    if current_user.instance_of? User
      redirect url(:new_activity)
    elsif current_user.instance_of? Client
      redirect url(:new_activity)
    elsif current_user.instance_of? Admin
      redirect url(:activities)
    else
      raise Forbidden
    end
  end
  
end # Front
