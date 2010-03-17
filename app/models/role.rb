class Role
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :required => true, :unique => true
  property :can_manage_financial_data, Boolean, :required => true, :default => false
  
  has n, :employees

  before :destroy do
    throw :halt if employees.count > 0
  end

  # class methods

  def self.for_select
    all.map { |r| [r.id, r.name] }
  end

  # instance methods

  def name=(name)
    raise 'The :name attribute is readonly' unless new? or name == self.name
    attribute_set(:name, name)
  end

end
