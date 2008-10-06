require 'digest'

class User
  include DataMapper::Resource

  property :id,            Serial
  property :name,          String, :nullable => false, :unique => true 
  property :type,          Discriminator
  property :password_hash, String
  property :login,         String, :nullable => false, :unique => true 
  property :email,         String, :nullable => false, :unique => true, :format => :email_address
  property :active,        Boolean, :nullable => false, :default => true
  property :created_at,    DateTime

  attr_accessor :password
  attr_accessor :password_confirmation

  validates_length :name, :min => 3

  validates_length :password, :min => 6 , :if => :password_required?
  validates_is_confirmed :password
  
  has n, :activities
  
  before :save do 
    self.password_hash = User.encrypt(self.password) if self.password
  end

  class << self
    def encrypt(string_fo_encryption)
      Digest::MD5.hexdigest(string_fo_encryption)
    end
  
    def authenticate(login, password)
      User.first :login => login, :password_hash => User.encrypt(password)
    end
  end
  
  def password_required?
    new_record? || self.password_hash.blank?
  end
  
  def is_admin?
    self.instance_of? Admin
  end
end
