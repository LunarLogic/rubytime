class Projects < Application

  before :login_required
  before :admin_required
  
  def index
    render
  end
  
end # Projects
