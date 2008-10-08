class Role
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false, :unique => true
  
  has n, :employees
end
