desc "send emails for RubyTime users"
namespace :rubytime do

  task :send_emails => :merb_env do
#    Merb::Mailer.delivery_method = :test_send
    for user in User.all(:remind_by_email => true)
      missed_days = user.indefinite_activities
      if missed_days.count > 0
        puts "Emailing #{user.name}"
        m = UserMailer.new(:user => user, :missed_days => missed_days)
        m.dispatch_and_deliver(:notice, :to => user.email, :from => Rubytime::CONFIG[:mail_from], :subject => "RubyTime reminder!")
      end
    end
  end
  
  desc 'Send timesheet nagger emails for previous weekday'
  task :send_timesheet_nagger_emails_for_previous_weekday => :merb_env do
    logger = daily_logger('timesheet_nagger')
    if Date.today.weekday?
      date = Date.today.previous_weekday
      Employee.send_timesheet_naggers_for__if_enabled(date, logger) 
    end
  end
  
  desc 'Send timesheet report email for previous weekday'
  task :send_timesheet_report_email_for_previous_weekday => :merb_env do
    if Date.today.weekday?
      Employee.send_timesheet_reporter_for__if_enabled(
        Date.today.previous_weekday, 
        Rubytime::CONFIG[:timesheet_report_addressee_email],
        Logger.new(Merb.root / "log/timesheet_reporter.log")
      )
    end
  end

  desc 'Send timesheet summary emails for last five days'
  task :send_timesheet_summary_emails_for_last_five_days => :merb_env do
    logger = daily_logger('timesheet_summary')
    Employee.send_timesheet_summary_for__if_enabled(
      (Date.today - 4)..(Date.today),
      logger
    )
  end

end

def daily_logger(relative_dir, date = Date.today)
  log_dir = Merb.root / "log" / relative_dir
  Dir.mkdir(log_dir) unless File.directory?(log_dir)
  Logger.new(log_dir / "#{date}.log")
end
