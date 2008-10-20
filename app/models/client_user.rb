class ClientUser < User
  belongs_to :client
  validates_present :client
end
