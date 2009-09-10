class Currencies < Application
  before :ensure_admin
  before :load_currencies, :only => [:index, :create]
  before :load_currency, :only => [:destroy]

  def index
    @currency = Currency.new
    render
  end
  
  def create
    @currency = Currency.new(params[:currency])
    if @currency.save
      redirect resource(:currencies)
    else
      render :index
    end
  end

  def destroy    
    if @currency.destroy
      render_success
    else
      render_failure "Currency is in use and cannot be deleted."
    end
  end
  
  protected
  def load_currencies
    @currencies = Currency.all
  end
  
  def load_currency
    @currency = Currency.get(params[:id]) or raise NotFound
  end
  
  def number_of_columns
    params[:action] == "edit" ? 1 : super
  end

end # Currencies
