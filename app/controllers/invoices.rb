class Invoices < Application
  before :ensure_admin, :exclude => [:index, :show]
  before :load_invoice, :only => [:edit, :update, :destroy, :show, :issue]
  before :load_invoices, :only => [:index, :create]
  before :load_clients, :only => [:index, :create, :edit]

  def index
    raise Forbidden if current_user.is_employee? && !current_user.is_admin?
    @invoice = Invoice.new
    render
  end
  
  def show
    raise Forbidden unless current_user.can_see_invoice?(@invoice)
    @activities = @invoice.activities.all(:order => [:created_at.desc])
    render
  end

  def edit
    raise Forbidden unless current_user.is_admin?
    render
  end

  def update
    if @invoice.update_attributes(params[:invoice]||{})
      if request.xhr?
        @invoice.to_json
      else
        redirect resource(@invoice), :message => { :notice => "Invoice has been updated" }
      end
    else
      render :edit, :status => 400, :layout => false
    end
  end
  
  def create
    @invoice = Invoice.new(params[:invoice].merge(:user_id => current_user.id))
    if @invoice.save
      request.xhr? ? "" : redirect(resource(:invoices))
    else
      if request.xhr?
        render_failure @invoice.errors.full_messages.reject { |m| m =~ /integer/ }.join(", ").capitalize
      else
        render :index
      end
    end
  end
  
  
  def destroy
    if @invoice.destroy
      render_success
    else
      render_failure "This invoice has been issued. Couldn't delete."
    end
  end
  
  def issue
    @invoice.issued_at = DateTime.now
    @invoice.save
    redirect resource(@invoice), :message => { :notice => "Invoice has been issued" }
  end

  protected
  def load_invoice
    @invoice = Invoice.get(params[:id]) or raise NotFound
  end

  def load_invoices
    filter = params[:filter] || :all
    @invoices = (current_user.is_client_user? ? current_user.client.invoices : Invoice.all).send(filter).all(:order => [:created_at.desc])
  end

  def load_clients
    @clients = Client.active.all(:order => [:name])
  end
  
  def number_of_columns
    params[:action] == "show" || (params[:action] == "index" || params[:action] == "create") && !current_user.is_admin? ? 1 : super
  end
end