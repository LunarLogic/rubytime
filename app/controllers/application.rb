require Merb.root / "lib/rubytime/authenticated_system"

class Application < Merb::Controller
  include Utype::AuthenticatedSystem
  
  protected
  
  def admin_required
    # why it doesn't redirect while running specs?
    # raise Forbidden unless current_user.is_admin? 
    redirect :controller => "Exceptions", :action => "forbidden" unless current_user.is_admin?
  end
end