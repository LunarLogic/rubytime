class Invoices < Application
  before :ensure_admin, :exclude => [:index]
  before :load_invoice, :only => [:edit, :update, :destroy, :show]
  before :load_invoices, :only => [:index, :create]
  before :load_clients, :only => [:index, :create]

  def index
    raise Forbidden if current_user.is_employee? && !current_user.is_admin?
    @invoice = Invoice.new
    render
  end
  
  def create
    @invoice = Invoice.create(params[:invoice].merge(:user_id => current_user.id))
    if @invoice.new_record?
      if request.xhr?
        render_failure @invoice.errors.full_messages.reject { |m| m =~ /integer/ }.join(", ").capitalize
      else
        render :index
      end
    else
      Activity.all(:id => params[:activity_id], :invoice_id => nil).update!(:invoice_id => @invoice.id) if params[:activity_id]
      request.xhr? ? "" : redirect(resource(:invoices))
    end
  end
  
  def update
    Activity.all(:id => params[:activity_id], :invoice_id => nil).update!(:invoice_id => @invoice.id) if params[:activity_id]
    ""
  end
  
  def destroy
    if @invoice.destroy
      render_success
    else
      render_failure "This invoice has been issued. Couldn't delete."
    end
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
end