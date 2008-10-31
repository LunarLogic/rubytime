class Invoices < Application
  before :login_required
  before :admin_required
  before :load_invoice, :only => [:edit, :update, :destroy, :show]

  def index
    @invoices = Invoice.all
    render
  end
  
  def create
    invoice = Invoice.create(params[:invoice].merge!(:user_id => current_user.id))
    if invoice.new_record?
      render_failure invoice.errors.full_messages.reject { |m| m =~ /integer/ }.join(", ").capitalize
    else
      Activity.all(:id => params[:activity_id], :invoice_id => nil).update!(:invoice_id => invoice.id)
      ""
    end
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
end