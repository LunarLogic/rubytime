class ClientUser < User
  property :client_id, Integer
  
  belongs_to :client
  validates_present :client
end
