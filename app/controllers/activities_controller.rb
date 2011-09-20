class ActivitiesController < ApplicationController
  # TODO: extract everything related to calendar to separated Calendar controller

  # TODO: Refactor. Methods from these helper are needed for the convert_to_csv method
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  respond_to :json
  
  before_filter :authenticate_user!
  before_filter :ensure_not_client_user,     :only => [:new, :create]
  before_filter :load_projects,              :only => [:new, :edit, :update, :create]
  before_filter :load_users,                 :only => [:new, :edit, :update, :create]
  before_filter :load_activity,              :only => [:edit, :update, :destroy]
  before_filter :load_activity_custom_properties, :only => [:new, :create, :edit, :update]
  before_filter :load_column_properties,     :only => [:index, :day]
  before_filter :load_owner,                 :only => [:calendar]
  before_filter :check_calendar_viewability, :only => [:calendar]
  before_filter :check_day_viewability,      :only => [:day]
  before_filter :check_deletable_by,         :only => [:destroy]
  before_filter :check_if_valid_project,     :only => [:create]
  
  protect_fields_for :activity, :in => [:create, :update], :always => [:price_value, :price_currency_id, :invoice_id]

  def index
    params[:search_criteria] ||= { :date_from => Date.today - current_user.recent_days_on_list }
    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    @search_criteria.user_id = [params[:user_id]] if params[:user_id]
    @search_criteria.project_id = [params[:project_id]] if params[:project_id]
    @search_criteria.include_inactive_projects = true if current_user.is_client_user?
    @activities = @search_criteria.found_activities

    if current_user.is_admin?
      @uninvoiced_activities = @activities.reject { |a| a.invoiced? }
      @clients = Client.active.all(:order => [:name])
      @invoices = Invoice.pending.all(:order => [:name])
      @invoice = Invoice.new
    end

    # prefetch activity associations - this is necessary to prevent DM from making crazy amounts of queries...
    # DM doesn't have :include, and SEL doesn't work in this case because the activities are filtered using select { }
    @activities.users
    @activities.roles
    @activities.projects.clients
    @activities.activity_custom_property_values
    @activities.map(&:comments)

    respond_to do |format|
      format.csv { render :text => convert_to_csv(@activities) }
      if request.xhr?
        format.html { render :index, :layout => false }
      else
        format.json { render(:json => @activities, :methods => [:locked?, :price_as_json, :role_name]) }
        format.html { render(:html => @activities, :methods => [:locked?, :price_as_json, :role_name]) }
      end
    end
  end
  
  def new
    preselected_user = current_user.is_admin? && !params[:user_id].blank? && User.get(params[:user_id])
    preselected_user ||= current_user
    @activity = Activity.new(
      :date => params[:date] || Date.today,
      :user => preselected_user,
      :project => (@recent_projects + @other_projects).first
    )
    @activity.main_activity_type = @activity.available_main_activity_types.first
    @activity.sub_activity_type = @activity.available_sub_activity_types.first
    render :layout => false
  end

  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user unless current_user.is_admin? && @activity.user
    
    if @activity.save
      render :json => @activity
    else
      respond_to do |format|
        format.json { render(:json => {:errors => @activity.errors.full_messages}, :status => 400) }
        format.any { render :new, :status => 400, :layout => false }
      end
    end
  end
  
  def edit
    render :layout => false
  end
  
  def update
    @activity.user = current_user unless current_user.is_admin?

    if @activity.update(params[:activity])
      respond_to do |format|
        format.json { render(:json => @activity) }
        format.html { render(:html => @activity) }
      end
    else
      respond_to do |format|
        format.json { render(:json => {:errors => @activity.errors.full_message }, :status => :bad_request) }
        format.html { render(:new, :status => :bad_request, :layout => false) }
      end
    end
  end
  
  def destroy
    if @activity.destroy
      render_success
    else
      render "Could not delete activity.", :status => 403
    end 
  end
  
  # TODO refactor
  def calendar
    if current_user.is_admin?
      if params[:user_id]
        @users = Employee.active.all(:order => [:name.asc])
      else
        @projects = Project.all(:order => [:name.asc])
      end
    elsif current_user.is_client_user?
      @projects = current_user.client.projects.all(:order => [:name.asc])
    end
    
    if params.has_key?("year") && params.has_key?("month")
      @year, @month = params[:year].to_i, params[:month].to_i
      date = { :year => @year, :month => @month }
    else
      @year, @month = Date.today.year, Date.today.month
      date = :this_month
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
                    render :nothing => true, :status => :bad_request and return
                  end
    @activities_by_date = @activities.group_by { |activity| activity.date }
    
    if request.xhr?
      render :text => activities_calendar(:activities => @activities_by_date, :year => @year, :month => @month, :owner => @owner), :layout => false
    else
      render
    end
  end
  
  def day
    @activities = SearchCriteria.new(params[:search_criteria], current_user).found_activities
    @day = Date.parse(params[:search_criteria][:date_from]).to_s(current_user.date_format)
    render :layout => false
  end


  protected

  def check_day_viewability
    user_id = params[:search_criteria][:user_id]
    project_id = params[:search_criteria][:project_id]

    bad_request and return if (user_id && user_id.size > 1) || (project_id && project_id.size > 1)

    if current_user.is_client_user? || current_user.is_admin? && project_id
      forbidden and return unless user_id.nil?
      not_found and return unless @owner = Project.get(project_id.first)
    else
      not_found and return unless @owner = User.get(user_id.first)
    end
    check_calendar_viewability
  end
  
  def check_deletable_by
    forbidden and return unless @activity.deletable_by?(current_user)
  end
  
  def check_calendar_viewability
    unless @owner.calendar_viewable?(current_user)
      render :nothing => true, :status => :forbidden and return
    end
  end

  def check_if_valid_project
    unless params[:activity] && Project.get(params[:activity][:project_id])
      render :new, :status => :bad_request, :layout => false
    end
  end

  def load_activity
    source = (current_user.is_admin?) ? Activity : current_user.activities
    not_found and return unless @activity = source.get(params[:id])
  end

  def load_owner
    if params[:user_id]
      not_found and return unless @owner = User.get(params[:user_id])
    else
      not_found and return unless @owner = Project.get(params[:project_id])
    end
  end

  def load_projects
    @recent_projects = current_user.recent_projects
    @other_projects = Project.active.all(:id.not => @recent_projects.map(&:id), :order => [:name])
  end
  
  def load_users
    @users = Employee.active.all(:order => [:name.asc]) if current_user.is_admin?
  end
  
  def load_activity_custom_properties
    @activity_custom_properties = ActivityCustomProperty.all
  end
  
  def convert_to_csv(activities)
    CSV.generate(:col_sep => ';') do |csv|
      custom_columns = ActivityCustomProperty.all.map { |p| p.name_with_unit }
      csv << %w(Client Project Role User Date Hours) + custom_columns + %w(Type SubType Comments)

      activities.each do |activity|
        custom_fields = ActivityCustomProperty.all.map { |p| format_number(activity.custom_properties[p.id]) }
        csv << [
          activity.project.client.name,
          activity.project.name,
          activity.role.name,
          activity.user.name,
          activity.date,
          format_number(activity.minutes / 60.0, :precision => 2)
        ] + custom_fields + [
          activity.main_activity_type && activity.main_activity_type.name,
          activity.sub_activity_type && activity.sub_activity_type.name,
          activity.comments.strip
        ]
      end
    end
  end
  
  def number_of_columns
    params[:action] == "calendar" ? 1 : super
  end
 
end
