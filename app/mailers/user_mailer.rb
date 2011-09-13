class UserMailer < ActionMailer::Base
  def welcome(params)
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end
  
  def password_reset_link(params)
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end

  def notice(params)
    @missed_days = params[:missed_days]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end
  
  def timesheet_nagger(params)
    @day_without_activities = params[:day_without_activities]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end
  
  def timesheet_reporter(params)
    @day_without_activities = params[:day_without_activities]
    @employees_without_activities = params[:employees_without_activities]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end
  
  def timesheet_summary(params)
    @dates_range = params[:dates_range]
    @activities_by_dates_and_projects = params[:activities_by_dates_and_projects]
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end
  
  def timesheet_changes_notifier(params)
    @project_manager = params[:project_manager]
    @kind_of_change = params[:kind_of_change]
    @activity = params[:activity]
    @url = Rubytime::CONFIG[:site_url]
    render_mail(params)
  end

  private

  # Helper for backwards compatibility with Merb
  def render_mail(params)
    mail(:to => params[:to], :from => params[:from], :subject => params[:subject])
  end

end
