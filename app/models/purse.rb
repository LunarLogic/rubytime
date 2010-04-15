class Purse
  def initialize
    @money_by_currency = {}
  end
  
  def <<(money)
    @money_by_currency[money.currency] ||= Money.new(0, money.currency)
    @money_by_currency[money.currency] += money
  end
  
  def currencies
    @money_by_currency.keys.sort_by { |currency| currency.singular_name }
  end
  
  def [](currency)
    @money_by_currency[currency] || Money.new(0, currency)
  end
  
  def to_s
    currencies.map { |currency| self[currency].to_s }.join(' and ')
  end

  def merge(other)
    other.currencies.each { |currency| self << other[currency] }
    self
  end

end
