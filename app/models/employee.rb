require 'logger'

class Employee < User
  validates_presence_of :role
  
  before :valid? do
    self.client_id = nil
  end
  
  before :destroy do
    throw :halt if activities.count > 0
  end

  def self.managers
    all('role.name' => 'Project Manager')
  end

  def can_manage_financial_data?
    is_admin? or role.can_manage_financial_data
  end
  
  def send_timesheet_nagger_for(date)
    UserMailer.timesheet_nagger(:user => self, 
                                :day_without_activities => date,
                                :from => Rubytime::CONFIG[:mail_from],
                                :to => email,
                                :subject => "RubyTime timesheet nagger for #{date}").
      deliver
  end
  
  def self.without_activities_on(date)
    all.reject { |employee| employee.has_activities_on?(date) }
  end
  
  def self.send_timesheet_naggers_for(date, logger = Logger.new(nil))
    Employee.without_activities_on(date).each do |employee|
      logger.info "Sending timesheet nagger email to #{employee.name}."
      employee.send_timesheet_nagger_for(date)
    end
  end
  
  def self.send_timesheet_naggers_for__if_enabled(date, logger = Logger.new(nil))
    if Setting.enable_notifications
      send_timesheet_naggers_for(date, logger)
    else
      logger.error "Won't send timesheet naggers: notifications are disabled."
    end
  end
  
  def self.send_timesheet_reporter_for(date, logger = Logger.new(nil))
    logger.info "Sending timesheet report email to #{email}."
    UserMailer.timesheet_reporter(
      :employees_without_activities => Employee.without_activities_on(date),
      :day_without_activities => date,
      :from => Rubytime::CONFIG[:mail_from],
      :to => Rubytime::CONFIG[:timesheet_report_addressee_email],
      :subject => "RubyTime timesheet report for #{date}"
    ).deliver
  end
  
  def self.send_timesheet_reporter_for__if_enabled(date, logger = Logger.new(nil))
    if Setting.enable_notifications
      send_timesheet_reporter_for(date, logger)
    else
      logger.error "Won't send timesheet report: notifications are disabled."
    end
  end
  
  def send_timesheet_summary_for(dates_range)
    UserMailer.timesheet_summary(
      :user => self,
      :dates_range => dates_range,
      :activities_by_dates_and_projects => activities_by_dates_and_projects(dates_range),
      :from => Rubytime::CONFIG[:mail_from],
      :to => email,
      :subject => "RubyTime timesheet summary for #{dates_range}"
    ).deliver
  end
  
  def activities_by_dates_and_projects(date_range)
    all_in_range = activities(:date => date_range, :order => ['created_at'])
    grouped_by_day = all_in_range.group_by { |a| a.date }
    grouped_by_day.default = []

    date_range.to_a.map do |date|
      all_on_date = grouped_by_day[date]
      grouped_by_project = all_on_date.group_by { |a| a.project }
      [date, grouped_by_project.map.sort_by { |project, activity| project.name }]
    end
  end
  
  def self.send_timesheet_summary_for(dates_range, logger = Logger.new(nil))
    all.each do |employee|
      logger.info "Sending timesheet summary email to #{employee.name}."
      employee.send_timesheet_summary_for(dates_range)
    end
  end
  
  def self.send_timesheet_summary_for__if_enabled(dates_range, logger = Logger.new(nil))
    if Setting.enable_notifications
      send_timesheet_summary_for(dates_range, logger)
    else
      logger.error "Won't send timesheet summary: notifications are disabled."
    end
  end
end
