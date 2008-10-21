class SearchCriteria # < OpenStruct
  attr_reader :date_from
  attr_reader :date_to
  attr_reader :client_id
  attr_reader :project_id
  attr_reader :role_id
  attr_reader :user_id
  attr_reader :invoiced
  attr_reader :errors
  
  def initialize(attrs)
    attrs && attrs.each do |attr, value|
      send("#{attr}=", value)
    end
    @errors = DataMapper::Validate::ValidationErrors.new
  end

  def user_id=(id_)
    return if id_.blank?
    @user_id = id_.to_i
  end
  
  def role_id=(id_)
    return if id_.blank?
    @role_id = id_.to_i
  end
  
  def client_id=(id_)
    return if id_.blank?
    @client_id = id_.to_i
  end

  def project_id=(id_)
    return if id_.blank?
    @project_id = id_.to_i
  end
  
  def date_from=(date)
    @date_from = Date.parse(date) rescue nil
  end

  def date_to=(date)
    @date_to = Date.parse(date) rescue nil
  end
  
  def invoiced=(bool)
    @invoiced = (bool == "1" ? true : false)
  end
  
  def clients
    Client.active.all(:order => [:name])
  end
  
  def projects
    projects_conditions = {}
    projects_conditions = { :client_id => @client_id } unless @client_id.blank? 
    Project.active.all({:order => [:name]}.merge(projects_conditions))
  end
  
  def roles
    Role.all(:order => [:name])
  end
  
  def users
    return @users if @users
    users_conditions = {}
    users_conditions = { :role_id => @role_id } unless @role_id.blank? 
    @users = Employee.active.all({:order => [:name]}.merge(users_conditions))
  end
  
  def activities
    user_ids = @user_id.blank? ? self.users.map { |u| u.id } : @user_id
    conditions = {}
    conditions.merge!(:user_id => user_ids) 
    conditions.merge!(:project_id => @project_id) unless @project_id.blank? 
    conditions.merge!(:date.gte => @date_from) unless @date_from.blank? 
    conditions.merge!(:date.lte => @date_to) unless @date_to.blank?
    Activity.all({:order => [:date.desc]}.merge(conditions))
  end
end
