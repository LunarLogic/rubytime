class Role
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false, :unique => true
  property :can_manage_financial_data, Boolean, :nullable => false, :default => false
  
  has n, :employees

  before :destroy do
    throw :halt if employees.count > 0
  end
  
  def self.for_select
    all.map { |r| [r.id, r.name] }
  end
end
