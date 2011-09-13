class UserMailer < ActionMailer::Base
  def welcome
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def password_reset_link
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end

  def notice
    @missed_days = params[:missed_days]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def timesheet_nagger
    @day_without_activities = params[:day_without_activities]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def timesheet_reporter
    @day_without_activities = params[:day_without_activities]
    @employees_without_activities = params[:employees_without_activities]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def timesheet_summary
    @dates_range = params[:dates_range]
    @activities_by_dates_and_projects = params[:activities_by_dates_and_projects]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def timesheet_changes_notifier
    @project_manager = params[:project_manager]
    @kind_of_change = params[:kind_of_change]
    @activity = params[:activity]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
end
