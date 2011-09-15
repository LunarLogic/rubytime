class CurrenciesController < ApplicationController
  before_filter :ensure_admin
  before_filter :load_currencies, :only => [:index, :create]
  before_filter :load_currency, :only => [:destroy]

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

  def edit
    @currency = Currency.get(params[:id]) or raise NotFound
    render
  end

  def update
    @currency = Currency.get(params[:id]) or raise NotFound
    if @currency.update(params[:currency]) || !@currency.dirty?
      redirect resource(:currencies)
    else
      render :edit
    end
  end

  def destroy    
    if @currency.destroy
      render_success
    else
      render_failure "Currency is in use and cannot be deleted."
    end
  end


  private

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
