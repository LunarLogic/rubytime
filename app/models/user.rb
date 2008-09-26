class User
  include DataMapper::Resource

  property :id,            Integer, :serial => true
  property :name,          String
  property :type,          Discriminator
  property :password_hash, String
  property :login,         String
  property :email,         String

end
