require File.join(File.dirname(__FILE__), "..", "spec_helper")

# Move this to your spec_helper.rb.
module MailControllerTestHelper
  # Helper to clear mail deliveries.
  def clear_mail_deliveries
    Merb::Mailer.deliveries.clear
  end

  # Helper to access last delivered mail.
  # In test mode merb-mailer puts email to
  # collection accessible as Merb::Mailer.deliveries.
  def last_delivered_mail
    Merb::Mailer.deliveries.last
  end

  # Helper to deliver
  def deliver(action, mail_params = {}, send_params = {})
    UserMailer.dispatch_and_deliver(action, { :from => "no-reply@webapp.com", :to => "recepient@person.com" }.merge(mail_params), send_params)
    @delivery = last_delivered_mail
  end
end

describe UserMailer, "#notify_on_event email template" do
  include MailControllerTestHelper
  
  before :each do
    clear_mail_deliveries
    
    # instantiate some fixture objects
    @user = Employee.gen
  end
    
  it "includes welcome phrase in email text" do
    deliver :welcome, {}, :user => @user, :url => Rubytime::CONFIG[:site_url]
    last_delivered_mail.text.should =~ /#{@user.name}, welcome/
    last_delivered_mail.text.should =~ /login: #{@user.login}/
    last_delivered_mail.text.should =~ /password: #{@user.password}/
    # last_delivered_mail.text.should =~ /#{Rubytime::CONFIG[:site_url]}/
  end
end