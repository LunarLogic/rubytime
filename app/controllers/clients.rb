class Clients < Application

  before :login_required
  before :admin_required
  
  def new
    @client_user = ClientUser.new
    @client_user.generate_password!
    @client = Client.new
    render
  end
  
  def create
    render
  end
  
  def index
    render
  end
  
end # Clients