class User
  include DataMapper::Resource
  
  property :id,            Serial
  property :name,          String, :nullable => false, :unique => true 
  property :type,          Discriminator
  property :password_hash, Rubytime::DatamapperTypes::SHA1Hash, :nullable => false
  property :login,         String, :nullable => false, :unique => true, :format => /^[\w_-]{3,20}$/
  property :email,         String, :nullable => false, :unique => true, :format => :email_address
  property :active,        Boolean, :nullable => false, :default => true
  property :admin,         Boolean, :nullable => false, :default => false
  property :created_at,    DateTime

  attr_accessor :password_confirmation
  attr_accessor :password
  
  validates_length :name, :min => 3

  validates_length :password, :min => 6 , :if => :password_required?
  validates_is_confirmed :password, :if => :password_required?
  
  has n, :activities #, :order => [:created_at.desc] - this order doesn't currently work when used in through relation below 
                     # according to lighthouse it's a bug in DM
  has n, :projects, :through => :activities
  
  def self.authenticate(login, password)
    User.first(:login => login, :password_hash => password, :active => true)
  end
  
  def password=(new_password)
    self.password_hash = new_password unless new_password.blank?
    @password = new_password
  end
  
  def password_required?
    new_record? || !password.blank? || !password_confirmation.blank? 
  end
  
  def is_admin?
    (!self.instance_of?(ClientUser)) && self.admin?
  end
  
  def editable_by?(user)
    user == self || user.is_admin?
  end
  
  def generate_password!
    if password.nil? && password_confirmation.nil?
      self.password = self.password_confirmation = Rubytime::Misc.generate_password 
    end
  end
end
