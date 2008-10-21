class SearchCriteria # < OpenStruct
  attr_reader :date_from
  attr_reader :date_to
  attr_reader :client_id
  attr_reader :project_id
  attr_reader :role_id
  #attr_reader :user_id
  attr_accessor :invoiced
  attr_reader :errors
  
  def initialize(attrs)
    @invoiced = "all"
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
  
  def clients
    Client.active.all(:order => [:name])
  end
  
  def projects
    return @projects if @projects
    conditions = {}
    conditions.merge!(:client_id => @client_id) unless @client_id.nil? 
    @projects = Project.active.all({:order => [:name]}.merge(conditions))
  end
  
  def roles
    Role.all(:order => [:name])
  end
  
  def users
    return @users if @users
    conditions = {}
    conditions.merge!(:role_id => @role_id) unless @role_id.nil? 
    @users = Employee.active.all({:order => [:name]}.merge(conditions))
  end
  
  def activities
    user_ids = @user_id || self.users.map { |u| u.id } 
    project_ids = @project_id || self.projects.map { |p| p.id }
    conditions = {}
    conditions.merge!(:user_id => user_ids) 
    conditions.merge!(:project_id => project_ids) 
    conditions.merge!(:date.gte => @date_from) unless @date_from.nil? 
    conditions.merge!(:date.lte => @date_to) unless @date_to.nil?
    if @invoiced == "invoiced"
      conditions.merge!(:invoice_id.not => nil)
    elsif @invoiced == "not_invoiced"
      conditions.merge!(:invoice_id => nil)
    end
    Activity.all({:order => [:date.desc]}.merge(conditions))
  end
  
  def method_missing(name, *args)
    if name.to_s =~ /(user|project|client|role)_id_(\d+)/
      nil
    end
  end
end
