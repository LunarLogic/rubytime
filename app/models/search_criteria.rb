class SearchCriteria # < OpenStruct
  attr_reader :date_from
  attr_reader :date_to
  #attr_reader :client_id
  attr_reader :project_id
  attr_reader :role_id
  #attr_reader :user_id
  attr_accessor :invoiced
  attr_reader :errors
  
  def initialize(attrs, current_user)
    @current_user = current_user
    @invoiced = "all"
    @user_id = []
    @role_id = []
    @client_id = []
    @project_id = []
    attrs && attrs.each do |attr, value|
      send("#{attr}=", value)
    end
    @errors = DataMapper::Validate::ValidationErrors.new
  end
  
  def client_ids
    @current_user.is_client_user? ? [@current_user.client_id] : @client_id
  end
  
  def user_ids
    if @current_user.is_admin? || @current_user.is_client_user?
      @user_id.empty? ? self.users.map { |u| u.id } : @user_id
    else
      [@current_user.id]
    end
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
    conditions.merge!(:client_id => self.client_ids) unless self.client_ids.empty?
    @projects = Project.active.all({:order => [:name]}.merge(conditions))
  end
  
  def roles
    Role.all(:order => [:name])
  end
  
  def users
    return @users if @users
    conditions = {}
    conditions.merge!(:role_id => @role_id) unless @role_id.empty? 
    @users = Employee.active.all({:order => [:name]}.merge(conditions))
  end
  
  def activities
    project_ids = @project_id.empty? ? self.projects.map { |p| p.id } : @project_id
    conditions = {}
    conditions.merge!(:user_id => self.user_ids) 
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
  
  def method_missing(name, arg=nil)
    return super unless name.to_s =~ /(user|project|client|role)_id_(\d+)/
    i = $2.to_i
    collection = instance_variable_get("@#{$1}_id")
    if arg # setter
      collection.send("[]=", i, arg.to_i) unless arg.blank?
      collection.compact!
      arg
    else # getter
      #collection.send("[]", i)
      nil
    end
  end
end
