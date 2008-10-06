class Invoice
  include DataMapper::Resource

  property :id,            Serial

  property :client_id,    Integer, :nullable => false
 
  belongs_to :client
  
end
