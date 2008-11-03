class Clients < Application
  before :ensure_admin
  before :load_client, :only => [:show, :edit, :destroy, :update]
  
  def new
    @client_user = ClientUser.new
    @client_user.generate_password!
    @client = Client.new
    render :template => "clients/edit"
  end
  
  def show
    render
  end
  
  def create
    @client = Client.new(params[:client])
    @client_user = ClientUser.new(params[:client_user].merge(:client => @client))
    if @client_user.valid?  && @client.valid?
      @client_user.save
      @client.save
      redirect resource(@client)
    else
      render :template => "clients/edit"
    end
  end
  
  def index
    @clients = Client.all(:order => [:name])
    render
  end
  
  def edit
    render
  end
  
  def update
    if @client.update_attributes(params[:client]) || !@client.dirty?
      redirect resource(@client)
    else
      raise BadRequest
    end
  end
  
  def destroy
    if @client.destroy
      render_success
    else
      render_failure("Couldn't delete client which has invoices")
    end 
  end
  
  protected
  
  def load_client
    raise NotFound unless @client = Client.get(params[:id])
  end
end # Clients