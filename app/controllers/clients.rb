class Clients < Application
  before :ensure_admin
  before :load_client, :only => [:show, :edit, :destroy, :update]
  before :load_clients, :only => [:index, :create]
  
  def show
    render
  end
  
  def create
    @client = Client.new(params[:client])
    @client_user = ClientUser.new(params[:client_user].merge(:client => @client))
    if @client_user.valid? && @client.valid?
      @client_user.save
      @client.save
      redirect resource(@client)
    else
      render :index
    end
  end
  
  def index
    @client_user = ClientUser.new
    @client_user.generate_password!
    @client = Client.new
    render
  end
  
  def edit
    render
  end
  
  def update
    if @client.update(params[:client]) || !@client.dirty?
      redirect resource(@client)
    else
      render :edit
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
  
  def load_clients
    @clients = Client.all(:order => [:name])
  end
  
  def number_of_columns
    params[:action] == "show" || params[:action] == "edit" ? 1 : super
  end
end # Clients