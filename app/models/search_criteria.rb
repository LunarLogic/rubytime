class SearchCriteria
  attr_reader :date_from
  attr_reader :date_to
  attr_accessor :invoiced
  attr_reader :errors
  
  def initialize(attrs, current_user)
    @current_user = current_user
    @invoiced = "all"
    @user_ids = []
    @role_ids = []
    @client_ids = []
    @project_ids = []
    attrs && attrs.each do |attr, value|
      send("#{attr}=", value)
    end
    @errors = DataMapper::Validate::ValidationErrors.new
  end
  
  def all_clients(conditions={})
    Client.active.all(conditions.merge!({ :order => [:name] }))
  end

  # Returns all projects for selected clients  
  def all_projects(conditions={})
    return @all_projects if @all_projects
    conditions.merge!(:client_id => self.selected_clients.map(&:id)) unless self.selected_clients.empty?
    @all_projects = Project.active.all({ :order => [:name] }.merge(conditions))
  end
  
  def all_roles(conditions={})
    Role.all(conditions.merge!({ :order => [:name] }))
  end
  
  # Returns all users for selected roles
  def all_users(conditions={})
    return @all_users if @all_users
    conditions.merge!(:role_id => self.selected_roles.map(&:id)) unless self.selected_roles.empty? 
    @all_users = Employee.active.all({ :order => [:name] }.merge(conditions))
  end
  
  # Returns selected clients only 
  # Takes user type into account
  def selected_clients
    if @current_user.is_client_user? 
      [@current_user.client]
    else
      conditions = @client_ids.empty? ? {} : { :id => @client_ids }
      self.all_clients(conditions)
    end
  end
  
  # Returns selected projects only
  # Takes user type into account
  def selected_projects
    @project_ids.empty? ? self.all_projects : self.all_projects(:id => @project_ids)
  end

  # Returns selected roles only
  # Takes user type into account
  def selected_roles
    conditions = @role_ids.empty? ? {} : { :id => @role_ids }
    self.all_roles(conditions)
  end

  # Returns selected users only
  # Takes user type into account
  def selected_users
    if @current_user.is_admin? || @current_user.is_client_user?
      @user_ids.empty? ? self.all_users : self.all_users(:id => @user_ids)
    else
      [@current_user]
    end
  end
  
  def date_from=(date)
    @date_from = Date.parse(date) rescue nil
  end

  def date_to=(date)
    @date_to = Date.parse(date) rescue nil
  end
  
  def activities
    conditions = {}
    conditions.merge!(:user_id => self.selected_users.map(&:id)) 
    conditions.merge!(:project_id => self.selected_projects.map(&:id)) 
    conditions.merge!(:date.gte => @date_from) unless @date_from.nil? 
    conditions.merge!(:date.lte => @date_to) unless @date_to.nil?
    @invoiced == "invoiced" ? conditions.merge!(:invoice_id.not => nil) : conditions.merge!(:invoice_id => nil)
    Activity.all({:order => [:date.desc]}.merge(conditions))
  end
  
  # Accessors for multiple user_id_X, project_id_X, client_id_X and role_id_X properties
  def method_missing(name, arg=nil)
    return super unless name.to_s =~ /(user|project|client|role)_id_(\d+)/
    i = $2.to_i
    collection = instance_variable_get("@#{$1}_ids")
    if arg # setter
      collection.send("[]=", i, arg.to_i) unless arg.blank?
      collection.compact!
      arg
    else # getter
      collection.send("[]", i)
    end
  end
end
