class User
  include DataMapper::Resource
  
  property :id,                            Serial
  property :name,                          String, :nullable => false, :unique => true
  property :type,                          Discriminator, :index => true
  property :login,                         String, :nullable => false, :unique => true, :index => true, :format => /^[\w_\.-]{3,20}$/
  property :email,                         String, :nullable => false, :unique => true, :format => :email_address
  property :active,                        Boolean, :nullable => false, :default => true
  property :admin,                         Boolean, :nullable => false, :default => false
  property :role_id,                       Integer, :index => true
  property :client_id,                     Integer, :index => true
  property :created_at,                    DateTime
  property :password_reset_token,          String
  property :password_reset_token_exp,      DateTime
  property :date_format,                   Enum[*::Rubytime::DATE_FORMAT_NAMES], :default => :european, :nullable => false
  property :recent_days_on_list,           Enum[*::Rubytime::RECENT_DAYS_ON_LIST], :default => ::Rubytime::RECENT_DAYS_ON_LIST.first,
    :nullable => false
  property :remember_me_token_expiration,  DateTime
  property :remember_me_token,             String
  property :remind_by_email,               Boolean, :nullable => false, :default => false
  property :activities_count,              Integer, :default => 0

  validates_length :name, :min => 3

  validates_length :password, :min => 6 , :if => :password_required?
  #validates_is_confirmed :password, :if => :password_required?

  belongs_to :role # only for Employee
  belongs_to :client # only for ClientUser
  
  has n, :activities #, :order => [:created_at.desc] - this order doesn't currently work when used in through relation below 
  # according to lighthouse it's a bug in DM
  has n, :projects, :through => :activities

  has n, :free_days
  
  def self.active
    all(:active => true)
  end

  def self.with_activities
    active.all(:activities_count.gt => 0, :unique => true)
  end

  def self.with_activities_for_client(client)
    active.all('activities.project.client_id' => client.id, :unique => true)
  end

  def authenticated?(password)
    crypted_password == encrypt(password) && active
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

  def user_type
    if is_client_user?
      :client_user
    elsif is_admin?
      :admin
    else
      :employee
    end
  end

  def can_see_users?
    self.is_admin? || self.is_client_user?
  end

  def can_see_clients?
    self.is_admin? || self.is_employee? 
  end
  
  def can_see_invoice?(invoice)
    self.is_admin? || invoice.client == self.client
  end

  def can_add_activity?
    self.instance_of?(Employee)
  end
  
  def can_manage_financial_data?
    is_admin?
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

  def remember_me!
    self.remember_me_token_expiration = 2.weeks.from_now
    self.remember_me_token = encrypt("#{email}--#{remember_me_token_expiration}")
    save
  end

  def forget_me!
    self.remember_me_token_expiration = self.remember_me_token = nil
    save
  end

  def self.authenticate_with_token(token)
    user = self.first(:remember_me_token => token)
    if user
      user.remember_me_token_expiration > DateTime.now ? user : nil
    end
  end
  
  def reset_password!
    generate_password!
    save
  end
  
  def generate_password_reset_token
    now = Time.now
    update(
      :password_reset_token => Digest::SHA1.hexdigest("-#{login}-#{now}-"),
      :password_reset_token_exp => now+Rubytime::PASSWORD_RESET_LINK_EXP_TIME)
  end

  def clear_password_reset_token!
    update(:password_reset_token => nil, :password_reset_token_exp => nil)
  end
  
  def class_name
    self.class.to_s
  end

  def indefinite_activities(from_date="#{Date.today.year}-#{Date.today.month}-1", to_date=Date.today.to_s)
    days = []
    Date.parse(from_date).upto(Date.parse(to_date)) do |thisday|
      days += [thisday] unless thisday.wday==0  or thisday.wday==6 or
        FreeDay.is_day_off(self, thisday) or Activity.is_activity_day(self, thisday)
    end
    days
  end

  def has_activities_on?(date)
    activities.count(:date => date) > 0
  end
  
end
