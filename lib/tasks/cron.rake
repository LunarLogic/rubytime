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
  
  desc 'Send timesheet nagger emails about missing activities'
  task :send_timesheet_nagger_emails => :merb_env do
#    Merb::Mailer.delivery_method = :test_send
    if Date.today.weekday?
      date = Date.today.previous_weekday
      Employee.send_timesheet_naggers_for__if_enabled(date, timesheet_nagger_logger(date)) 
    end
  end
  
  desc 'Send timesheet report email about missing activities'
  task :send_timesheet_report_email => :merb_env do
#    Merb::Mailer.delivery_method = :test_send
    if Date.today.weekday?
      Employee.send_timesheet_reporter_for__if_enabled(
        Date.today.previous_weekday, 
        Rubytime::CONFIG[:timesheet_report_addressee_email],
        Logger.new(Merb.root / "log/timesheet_reporter.log")
      )
    end
  end


end

def timesheet_nagger_logger(date)
  log_dir = Merb.root / "log/timesheet_nagger/"
  Dir.mkdir(log_dir) unless File.directory?(log_dir)
  Logger.new(log_dir / "#{date}.log")
end
