class Client
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false
  property :description,  Text
  property :email,        String
  
  has n, :projects
  has n, :invoices
  
  def self.active
    all(:active => true)
  end
end
