class ClientUser < User
  property :client_id, Integer
  
  belongs_to :client
end
