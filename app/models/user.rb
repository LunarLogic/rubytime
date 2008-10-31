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
  property :role_id,       Integer
  property :created_at,    DateTime

  attr_accessor :password_confirmation
  attr_accessor :password
  
  validates_length :name, :min => 3
  validates_present :role, :if => proc { |u| u.class.to_s == "Employee" }

  validates_length :password, :min => 6 , :if => :password_required?
  validates_is_confirmed :password, :if => :password_required?

  
  belongs_to :role # only for Employee
  has n, :activities #, :order => [:created_at.desc] - this order doesn't currently work when used in through relation below 
                     # according to lighthouse it's a bug in DM
  has n, :projects, :through => :activities
    
  def self.active
    all(:active => true)
  end

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
    !self.is_client_user? && self.admin?
  end

  def is_client_user?
    self.instance_of?(ClientUser)
  end
  
  def is_employee?
    self.instance_of?(Employee)
  end
  
  def can_see_users?
    self.is_admin? || self.is_client_user?
  end

  def can_see_clients?
    self.is_admin? || self.is_employee? 
  end
  
  def editable_by?(user)
    user == self || user.is_admin?
  end
  
  def calendar_viewable?(user)
    user == self || user.is_admin?
  end
  
  def generate_password!
    if password.nil? && password_confirmation.nil?
      self.password = self.password_confirmation = Rubytime::Misc.generate_password 
    end
  end
end
