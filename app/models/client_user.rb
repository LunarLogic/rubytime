class ClientUser < User
  validates_present :client
  
  before :valid? do
    self.role_id = nil
  end
end
