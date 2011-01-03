class User
  include DataMapper::Resource

  RECENT_ACTIVITIES_NUM = 3
  LOGIN_REGEXP = /^[\w_\.-]{3,20}$/

  property :id,                            Serial
  property :name,                          String, :required => true
  property :type,                          Discriminator, :index => true
  property :login,                         String, :required => true, :index => true, :format => LOGIN_REGEXP
  property :ldap_login,                    String, :format => LOGIN_REGEXP, :unique => true
  property :email,                         String, :required => true, :format => :email_address
  property :active,                        Boolean, :required => true, :default => true
  property :admin,                         Boolean, :required => true, :default => false
  property :role_id,                       Integer, :index => true
  property :client_id,                     Integer, :index => true
  property :created_at,                    DateTime
  property :modified_at,                   DateTime  # not updated_at on purpose
  property :password_reset_token,          String
  property :password_reset_token_exp,      DateTime
  property :date_format,                   Enum[*Rubytime::DATE_FORMAT_NAMES],
                                             :required => true,
                                             :default => :european
  property :recent_days_on_list,           Enum[*Rubytime::RECENT_DAYS_ON_LIST],
                                             :required => true,
                                             :default => Rubytime::RECENT_DAYS_ON_LIST.first
  property :remember_me_token_expiration,  DateTime
  property :remember_me_token,             String
  property :remind_by_email,               Boolean, :required => true, :default => false
  property :activities_count,              Integer, :default => 0
  property :decimal_separator,             Enum[*Rubytime::DECIMAL_SEPARATORS],
                                             :required => true,
                                             :default => Rubytime::DECIMAL_SEPARATORS.first

  validates_length :name, :min => 3

  validates_length :password, :min => 6 , :if => :password_required?
  #validates_is_confirmed :password, :if => :password_required?

  validates_with_method :login, :method => :validates_login_globally_unique
  validates_with_method :name, :method => :validates_name_globally_unique
  validates_with_method :email, :method => :validates_email_globally_unique

  [:login, :name, :email].each do |attr|
    define_method "validates_#{attr}_globally_unique" do
      db_user = User.first(attr => self.send(attr))
      if db_user.blank? || db_user.id == self.id
        true
      else
        [false, "#{attr.to_s.capitalize} is already taken."]
      end 
    end
  end

  belongs_to :role # only for Employee
  belongs_to :client # only for ClientUser
  
  has n, :activities, :order => [:created_at.desc]
  has n, :projects, :through => :activities
  has n, :versions, :model => UserVersion, :child_key => :id
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

  def recent_projects
    self.projects.active.sort_by { |p| self.last_activity_in_project(p).date }.reverse.first(RECENT_ACTIVITIES_NUM)
  end

  def last_activity_in_project(project)
    self.activities.first(:project_id => project.id, :order => [:date.desc])
  end

  def authenticated?(password)
    (Auth::LDAP.authenticate(ldap_login, password) || crypted_password == encrypt(password) ) && active

  end
  class << self
    def authenticate(login, password)
      u = (User.all(:login => login)+User.all(:ldap_login => login)).first
      u && u.authenticated?(password) ? u : nil
    end
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

  def has_free_day_on(day)
    free_days.count(:date => day) > 0
  end

  def has_activities_on_day(day)
    activities.count(:date => day) > 0
  end

  def days_without_activities(from_date = Date.today.first_day_of_month, to_date = Date.today)
    range = (from_date..to_date)
    range.reject { |day| day.weekend? || has_free_day_on(day) || has_activities_on_day(day) }
  end

  def has_activities_on?(date)
    activities.count(:date => date) > 0
  end

  def becomes(klass)
    became = klass.new(attributes.merge(:type => klass))
    self.instance_variables.each do |v|
      unless became.respond_to?("#{v}=")
        became.instance_variable_set(v, self.instance_variable_get(v))
      end
    end
    became.type = klass
    became
  end

  def version(date)
    # find a role that the user had at the end of that day
    midnight = Time.parse("#{date.year}-#{date.month}-#{date.day}") + 1.day
    matching_version = versions.first(:modified_at.lt => midnight, :order => :version_id.desc)
    matching_version || versions.first || save_first_version
  end

  def versioned_attributes
    attributes.reject { |k, v| !UserVersion.properties.named?(k) }
  end

  def save_new_version
    UserVersion.create(versioned_attributes)
  end

  def save_first_version
    # this won't be called for new users, but will be called once for users created before this code was added
    version_attributes = versioned_attributes
    version_attributes[:modified_at] = self.created_at
    original_attributes.each do |property, value|
      if version_attributes.has_key?(property.name) # ignore not versioned attributes
        version_attributes[property.name] = value
      end
    end
    UserVersion.create(version_attributes)
  end

end
