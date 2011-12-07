class InvoicesController < ApplicationController
  include InvoicesHelper

  before_filter :ensure_admin, :except => [:index, :show]
  before_filter :load_invoice, :only => [:edit, :update, :destroy, :show, :issue]
  before_filter :load_invoices, :only => [:index, :create]
  before_filter :load_clients, :only => [:index, :create, :edit]
  before_filter :load_column_properties, :only => [:show]

  def index
    forbidden and return unless current_user.is_client_user? || current_user.is_admin?
    @invoice = Invoice.new
    render
  end
  
  def show
    forbidden and return unless current_user.can_see_invoice?(@invoice)
    @activities = @invoice.activities.all(:order => [:created_at.desc])
    render
  end

  def edit
    forbidden and return unless current_user.is_admin?
    render
  end

  def update
    if @invoice.update(params[:invoice]||{})
      if request.xhr?
        @invoice.to_json
      else
        redirect_to invoice_path(@invoice, filter_hash), :notice => "Invoice has been updated"
      end
    else
      load_clients
      
      render :edit
    end
  end
  
  def create
    @invoice = Invoice.new(params[:invoice].merge(:user_id => current_user.id))
    if @invoice.save
      if request.xhr?
        head :ok
      else
        redirect_to(invoices_path)
      end
    else
      if request.xhr?
        render_failure smart_errors_format(@invoice.errors)
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
    @invoice.issue!
    redirect_to invoices_path(@invoice), :message => { :notice => "Invoice has been issued" }
  rescue Exception => e
    load_column_properties
    @activities = @invoice.activities.all(:order => [:created_at.desc])
    flash[:error] = e.to_s
    render :show
  end

  protected

  def load_invoice
    @invoice = Invoice.get!(params[:id])
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
