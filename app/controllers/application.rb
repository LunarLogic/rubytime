class Application < Merb::Controller
  before :ensure_authenticated
  
  def current_user
    session.user
  end
  
  protected
  
  def ensure_admin
    raise Forbidden unless current_user.is_admin?
  end
  
  def render_success(content = "", status = 200)
    render content, :layout => false, :status => status 
  end
  
  def render_failure(content = "", status = 400)
    render content, :layout => false, :status => status
  end
  
  def number_of_columns
    2
  end
end