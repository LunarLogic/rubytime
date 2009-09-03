class Role
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false, :unique => true
  property :can_manage_financial_data, Boolean, :nullable => false, :default => false
  
  has n, :employees
  
  def name=(name)
    raise 'The :name attribute is readonly' unless new_record? or name == self.name
    attribute_set(:name, name)
  end

  before :destroy do
    throw :halt if employees.count > 0
  end
  
  def self.for_select
    all.map { |r| [r.id, r.name] }
  end
end
