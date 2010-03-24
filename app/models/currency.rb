class Currency
  include DataMapper::Resource
  
  PREFIX_REGEX = SUFFIX_REGEX = /^[^0-9]*$/
  
  property :id, Serial
  property :singular_name, String, :required => true
  property :plural_name,   String, :required => true
  property :prefix,        String
  property :suffix,        String
  
  validates_is_unique :singular_name, :plural_name
  validates_format :prefix, :with => PREFIX_REGEX, :if => proc { |c| not c.prefix.nil? }
  validates_format :suffix, :with => SUFFIX_REGEX, :if => proc { |c| not c.suffix.nil? }
  validates_format :singular_name, :plural_name, :with => /^\w\D\S*$/
  
  default_scope(:default).update(:order => [:singular_name])
  
  def render(value)
    "#{prefix}#{format('%.2f',value)}#{suffix}"
  end
  
end
