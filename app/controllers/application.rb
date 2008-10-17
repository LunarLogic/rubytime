class Application < Merb::Controller
  protected
  
  def admin_required
    raise Forbidden unless current_user.is_admin?
  end
  
  def render_success(content = "", status = 200)
    render content, :layout => false, :status => status 
  end
  
  def render_failure(content = "", status = 400)
    render content, :layout => false, :status => status
  end
end