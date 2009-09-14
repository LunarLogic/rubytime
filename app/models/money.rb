class Money

  include Comparable

  attr_reader :value, :currency

  def initialize(value,currency)
    self.value = value
    self.currency = currency
  end
  
  def value=(value)
    raise ArgumentError if value.nil?
    @value = value
  end

  def currency=(currency)
    raise ArgumentError if currency.nil?
    @currency = currency
  end

  def to_s
    currency.render(value)
  end

  def +(other)
    raise ArgumentError unless currency == other.currency
    Money.new(value + other.value, currency)
  end

  def *(numeric)
    raise ArgumentError unless numeric.is_a?(Numeric)
    Money.new(value * numeric, currency)
  end
  
  def <=>(other)
    raise ArgumentError.new('Cannot compare different currencies') unless currency == other.currency
    value <=> other.value
  end
 
end
