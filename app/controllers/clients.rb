class Clients < Application

  before :login_required
  before :admin_required
  
  def new
    render
  end
  
  def create
    render
  end
  
  def index
    render
  end
  
end # Clients
