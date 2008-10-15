class Application < Merb::Controller
  protected
  
  def admin_required
    raise Forbidden unless current_user.is_admin?
  end
  
  # def selected_menu_item; end
end