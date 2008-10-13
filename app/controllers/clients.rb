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
    @client = Client.new(params[:client])
    @client_user = ClientUser.new(params[:client_user].merge(:client => @client))
    begin
      @client.transaction.link(@client_user) do 
        raise "save_error" unless @client.save
        raise "save_error" unless @client_user.save
      end
    rescue => ex
      if ex.to_s == "save_error"
        render :template => "new"
      else
        raise ex
      end
    else
      redirect url(:clients)
    end
  end
  
  def index
    render
  end
  
end # Clients