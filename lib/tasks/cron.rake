desc "send emails for RubyTime users"
namespace :rubytime do

  task :test_task => :merb_env do
    puts 'ania'
  end

  # personal notification sent to all employees that missed a day this month,
  # with a list of days without activities
  # TODO: rename this?...
  task :send_emails => :merb_env do
    for user in User.all(:remind_by_email => true)
      missed_days = user.days_without_activities
      if missed_days.count > 0
        puts "Emailing #{user.name}"
        m = UserMailer.new(:user => user, :missed_days => missed_days)
        m.dispatch_and_deliver(:notice,
          :from => Rubytime::CONFIG[:mail_from],
          :to => user.email,
          :subject => "RubyTime reminder!"
        )
      end
    end
  end
  
  # personal notification sent to all employees that didn't add an activity yesterday
  desc 'Send timesheet nagger emails for previous weekday'
  task :send_timesheet_nagger_emails_for_previous_weekday => :merb_env do
    if Date.today.weekday?
      logger = daily_logger('timesheet_nagger')
      date = Date.today.previous_weekday
      Employee.send_timesheet_naggers_for__if_enabled(date, logger) 
    end
  end

  # list of employees that didn't add an activity yesterday, sent to the manager
  desc 'Send timesheet report email for previous weekday'
  task :send_timesheet_report_email_for_previous_weekday => :merb_env do
    if Date.today.weekday?
      logger = Logger.new(Merb.root / "log/timesheet_reporter.log")
      date = Date.today.previous_weekday
      Employee.send_timesheet_reporter_for__if_enabled(date, logger)
    end
  end

  # summary for activities from last five days, sent to the employee
  desc 'Send timesheet summary emails for last five days'
  task :send_timesheet_summary_emails_for_last_five_days => :merb_env do
    logger = daily_logger('timesheet_summary')
    date_range = (Date.today - 4)..(Date.today)
    Employee.send_timesheet_summary_for__if_enabled(date_range, logger)
  end

end

def daily_logger(relative_dir, date = Date.today)
  log_dir = Merb.root / "log" / relative_dir
  Dir.mkdir(log_dir) unless File.directory?(log_dir)
  Logger.new(log_dir / "#{date}.log")
end
