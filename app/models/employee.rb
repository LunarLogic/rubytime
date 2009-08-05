require 'logger'

class Employee < User
  validates_present :role
  
  has n, :activities
  
  before :destroy do
    throw :halt if activities.count > 0
  end
  
  def send_timesheet_nagger_for(date)
    m = UserMailer.new(:user => self, :day_without_activities => date)
    m.dispatch_and_deliver(:timesheet_nagger, :to => email, :from => Rubytime::CONFIG[:mail_from], :subject => "RubyTime timesheet nagger!")
  end
  
  def self.send_timesheet_naggers_for(date, logger = Logger.new(nil))
    all.reject { |employee| employee.has_activities_on?(date) }.each do |employee|
      logger.info "Sending timesheet nagger email to #{employee.name}."
      employee.send_timesheet_nagger_for(date)
    end
  end
  
  def self.send_timesheet_reporter_for(date, email, logger = Logger.new(nil))
    m = UserMailer.new(:employees_without_activities => all.reject { |employee| employee.has_activities_on?(date) }, :day_without_activities => date)
    m.dispatch_and_deliver(:timesheet_reporter, :to => email, :from => Rubytime::CONFIG[:mail_from], :subject => "RubyTime timesheet report")
  end
end
