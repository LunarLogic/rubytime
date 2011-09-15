class ClientUser < User
  validates_presence_of :client
  
  before :valid? do
    self.role_id = nil
  end
end
