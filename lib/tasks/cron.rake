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

end
