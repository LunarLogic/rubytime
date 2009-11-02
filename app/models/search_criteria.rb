class SearchCriteria
  attr_reader :selected_client_ids
  attr_reader :selected_project_ids
  attr_reader :selected_role_ids
  attr_reader :selected_user_ids
  attr_reader :date_from
  attr_reader :date_to
  attr_accessor :invoiced
  attr_accessor :limit
  attr_accessor :offset
  attr_accessor :since_activity
  attr_reader :errors
  
  def initialize(attrs, current_user)
    @current_user = current_user
    @invoiced = "all"
    @selected_user_ids = []
    @selected_role_ids = []
    @selected_client_ids = []
    @selected_project_ids = []
    @limit = nil
    @offset = 0
    @since_activity = nil
    attrs && attrs.each do |attr, value|
      send("#{attr}=", value) if respond_to?("#{attr}=")
    end
    @errors = DataMapper::Validate::ValidationErrors.new
  end
  
  # setters

  def date_from=(date)
    @date_from = date.is_a?(Date) ? date : (Date.parse(date) rescue nil)
  end

  def date_to=(date)
    @date_to = date.is_a?(Date) ? date : (Date.parse(date) rescue nil)
  end
  
  # Setters for multiple user_id[], project_id[], client_id[] and role_id[] properties
  [:user, :client, :project, :role].each do |prop|
    define_method "#{prop}_id=" do |value|
      instance_variable_set("@selected_#{prop}_ids", value.reject { |v| v.blank? })
    end
  end

  # finders
  
  def all_clients(conditions={})
    Client.active.all(conditions.merge!({ :order => [:name] }))
  end

  # Returns all projects for found clients  
  def all_projects(conditions={})
    return @all_projects if @all_projects
    conditions.merge!(:client_id => get_ids(self.found_clients)) unless self.found_clients.empty?
    @all_projects = Project.active.all({ :order => [:name] }.merge(conditions))
  end
  
  def all_roles(conditions={})
    Role.all(conditions.merge!({ :order => [:name] }))
  end
  
  # Returns all users for found roles
  def all_users(conditions={})
    return @all_users if @all_users
    conditions.merge!(:role_id => get_ids(self.found_roles)) unless self.found_roles.empty? 
    @all_users = Employee.active.all({ :order => [:name] }.merge(conditions))
  end
  
  # Returns found clients only 
  # Takes user type into account
  def found_clients
    if @current_user.is_client_user? 
      [@current_user.client]
    else
      conditions = @selected_client_ids.empty? ? {} : { :id => @selected_client_ids }
      self.all_clients(conditions)
    end
  end
  
  # Returns found projects only
  # Takes user type into account
  def found_projects
    @selected_project_ids.empty? ? self.all_projects : self.all_projects(:id => @selected_project_ids)
  end

  # Returns found roles only
  # Takes user type into account
  def found_roles
    conditions = @selected_role_ids.empty? ? {} : { :id => @selected_role_ids }
    self.all_roles(conditions)
  end

  # Returns found users only
  # Takes user type into account
  def found_users
    if @current_user.is_admin? || @current_user.is_client_user?
      @selected_user_ids.empty? ? self.all_users : self.all_users(:id => @selected_user_ids)
    else
      [@current_user]
    end
  end
  
  def found_activities
    conditions = {}
    conditions.merge!(:user_id => get_ids(self.found_users)) 
    conditions.merge!(:project_id => get_ids(self.found_projects)) 
    conditions.merge!(:date.gte => @date_from) unless @date_from.nil? 
    conditions.merge!(:date.lte => @date_to) unless @date_to.nil?
    conditions.merge!(:limit => @limit.to_i) if @limit
    conditions.merge!(:offset => @offset.to_i)
    conditions.merge!(:id.gt => @since_activity.to_i) if @since_activity
    case @invoiced
    when "invoiced"
      conditions.merge!(:invoice_id.not => nil)
    when "not_invoiced"
      conditions.merge!(:invoice_id => nil)
    end
    Activity.all({:order => [:date.desc, :created_at.desc]}.merge(conditions))
  end

  protected
  
  def get_ids(collection)
    collection.map { |o| o.id }
  end
end
