class Clients < Application

  before :login_required
  before :admin_required
  before :get_client, :only => [:show, :edit, :destroy, :update]
  
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
    begin
      DataMapper::Transaction.new(@client, @client_user) do # TODO: refactor transaction
        raise "save_error" unless @client.save
        raise "save_error" unless @client_user.save
      end
    rescue => ex
      if ex.to_s == "save_error"
        render :template => "clients/edit"
      else
        raise ex
      end
    else
      redirect url(:clients)
    end
  end
  
  def index
    @clients = Client.all
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
    @client.destroy
    redirect url(:clients)
  end
  
  protected
  
  def get_client
    raise NotFound unless @client = Client.get(params[:id])
  end
end # Clients