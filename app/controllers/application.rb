class Application < Merb::Controller

  protected
  
  def admin_required
    raise Forbidden unless current_user.is_admin?
  end
end