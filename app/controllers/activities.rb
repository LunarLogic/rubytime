class Activities < Application
  # TODO: extract everything related to calendar to separated Calendar controller
  RECENT_ACTIVITIES_NUM = 3
    
  before :load_projects,              :only => [:new, :edit, :update, :create]
  before :load_all_users,             :only => [:new, :edit, :update, :create] 
  before :load_owner,                 :only => [:calendar]
  before :check_calendar_viewability, :only => [:calendar]
  before :check_day_viewability     , :only => [:day]
  before :load_activity             , :only => [:edit, :update, :destroy]
  before :check_deletable_by        , :only => [:destroy] 

  def index
    provides :csv
    @search_criteria = SearchCriteria.new(params[:search_criteria] || { :date_from => Date.today - 7}, current_user)
    @activities = @search_criteria.found_activities
    if current_user.is_admin?
      @uninvoiced_activities = @activities.reject { |a| a.invoiced? }
      @clients = Client.active.all(:order => [:name])
      @invoices = Invoice.pending.all(:order => [:name])
      @invoice = Invoice.new
    end
    if content_type == :csv
      convert_to_csv(@activities)
    elsif request.xhr?
      render :index, :layout => false
    else
      render
    end
  end
  
  def new
    preselected_user = (current_user.is_admin? && !params[:user_id].blank? && User.get(params[:user_id])) || current_user
    @activity = Activity.new(:date => Date.today, :user => preselected_user)
    render :layout => false
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user unless current_user.is_admin?
    if @activity.save
      render partial("activity", :with => @activity), :status => 201, :layout => false 
    else
      render :new, :status => 400, :layout => false
    end
  end
  
  def edit
    render :layout => false
  end
  
  def update
    @activity.attributes = params[:activity]
    @activity.user = current_user unless current_user.is_admin?
    if @activity.save || !@activity.dirty?
      render "", :status => 200, :layout => false
    else
      render :edit, :status => 400, :layout => false
    end
  end
  
  def destroy
    if @activity.destroy
      render "", :status => 200
    else
      render "Could not delete activity.", :status => 403
    end 
  end

  # TODO refactor
  def calendar
    @users = Employee.active.all(:order => [:name.asc]) if current_user.is_admin?
    @projects = current_user.client.projects.all(:order => [:name.asc]) if current_user.is_client_user?
    
    date = if params.has_key?("year") && params.has_key?("month")
             @year, @month = params[:year].to_i, params[:month].to_i
             { :year => @year, :month => @month }
           else
             @year, @month = Date.today.year, Date.today.month
             :this_month
           end

    if @month == Date.today.month && @year == Date.today.year 
      @next_year      = @next_month = nil
    else
      @next_month     = @month == 12 ? 1 : @month.next
      @next_year      = @month == 12 ? @year.next : @year
    end
    
    @previous_month = @month == 1 ? 12 : @month.pred
    @previous_year  = @month == 1 ? @year.pred : @year
    
    @activities = begin 
                    @owner.activities.for date
                  rescue ArgumentError
                    raise BadRequest
                  end
    @activities_by_date = @activities.group_by { |activity| activity.date }
    
    if request.xhr?
      partial 'calendar_table'
    else
      render
    end
  end
  
  def day
    @activities = SearchCriteria.new(params[:search_criteria], current_user).found_activities
    @day = format_date(Date.parse(params[:search_criteria][:date_from]))
    raise BadRequest if @activities.empty?
    render :layout => false
  end
  
  protected
  
  def check_day_viewability
    raise BadRequest if params[:search_criteria][:user_id] && params[:search_criteria][:user_id].size > 1 || params[:search_criteria][:project_id] && params[:search_criteria][:project_id].size > 1
    if current_user.is_client_user? 
      raise Forbidden if !params[:search_criteria][:user_id].nil?
      @owner = Project.get(params[:search_criteria][:project_id].first) or raise NotFound
    else
      @owner = User.get(params[:search_criteria][:user_id].first) or raise NotFound
    end
    check_calendar_viewability
  end
  
  def check_deletable_by
    @activity.deletable_by?(current_user) or raise Forbidden
  end
  
  def check_calendar_viewability
    @owner.calendar_viewable?(current_user) or raise Forbidden
  end

  def load_activity
    @activity = Activity.get(params[:id]) or raise NotFound
  end
  
  def load_owner
    if params[:user_id]
      @owner = User.get(params[:user_id]) or raise NotFound
    else
      @owner = Project.get(params[:project_id]) or raise NotFound
    end
  end

  def load_projects
    @recent_projects = current_user.projects.active.sort_by { |p| Activity.first(:project_id => p.id, :user_id => current_user.id, 
                                                                                 :order => [:date.desc]).date }
    @recent_projects = @recent_projects.reverse[0...RECENT_ACTIVITIES_NUM]
    # .all(:order => ["activities.created_at DESC"], :limit => RECENT_ACTIVITIES_NUM)
    @other_projects = Project.active.all(:order => [:name]) - @recent_projects
  end
  
  def load_all_users
    @users = Employee.active.all(:order => [:name.asc]) if current_user.is_admin?
  end
  
  def convert_to_csv(activities)
    report = StringIO.new
    CSV::Writer.generate(report, ',') do |csv|
      csv << %w(Client Project Role User Date Hours Comments)
      activities.each do |activity|
        csv << [activity.project.client.name, activity.project.name, activity.user.role.name, activity.user.name, 
                activity.date, format("%.2f", activity.minutes / 60.0), activity.comments.strip]
      end
    end
    report.rewind
    report.read
  end
  
  def number_of_columns
    params[:action] == "calendar" ? 1 : super
  end
 
end # Activities
