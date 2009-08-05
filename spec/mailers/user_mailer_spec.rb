require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserMailer do
  include MailControllerTestHelper
  
  before :each do
    clear_mail_deliveries
    @user = Employee.gen(:password_reset_token => "1234asdjfggh3f2e44rtsdfhg", :role => fx(:developer))
    @another_user = Employee.gen(:password_reset_token => "1234asdjfggh3f2e44rtsdfhg", :role => fx(:developer))
  end
    
  it "includes welcome phrase, login, password and site url in welcome mail" do
    deliver :welcome, {}, :user => @user, :url => Rubytime::CONFIG[:site_url]
    last_delivered_mail.text.should include("#{@user.name}, welcome")
    last_delivered_mail.text.should include("login: #{@user.login}")
    last_delivered_mail.text.should include("password: #{@user.password}")
    last_delivered_mail.text.should include(Rubytime::CONFIG[:site_url])
  end
  
  it "includes password_reset_token and site url in password reset mail" do
    deliver :password_reset_link, {}, :user => @user, :url => Rubytime::CONFIG[:site_url]
    last_delivered_mail.text.should include("Hello, #{@user.name}")
    last_delivered_mail.text.should include(@user.password_reset_token)
    last_delivered_mail.text.should include(Rubytime::CONFIG[:site_url])
  end

  it "includes login, missed days and site url" do
    deliver :notice, {}, :user => @user, :url => Rubytime::CONFIG[:site_url], :missed_days => ["05/04/2009", "06/06/2009"]
    last_delivered_mail.text.should include("Hello #{@user.name},")
    last_delivered_mail.text.should include("05/04/2009\n  06/06/2009\n")
  end
  
  describe '#timesheet_nagger' do
    it "includes username, day without activities and site url" do
      deliver :timesheet_nagger, {}, :user => @user, :url => Rubytime::CONFIG[:site_url], :day_without_activities => Date.today
      last_delivered_mail.text.should include("Hello #{@user.name},")
      last_delivered_mail.text.should include("#{Date.today}")
      last_delivered_mail.text.should include("#{Rubytime::CONFIG[:site_url]}")
    end
  end
  
  describe '#timesheet_reporter' do
    it "includes day without activities, usernames and site url" do
      deliver :timesheet_reporter, {}, :employees_without_activities => [@user, @another_user], :url => Rubytime::CONFIG[:site_url], :day_without_activities => Date.today
      last_delivered_mail.text.should include("#{@user.name}")
      last_delivered_mail.text.should include("#{@another_user.name}")
      last_delivered_mail.text.should include("#{Date.today}")
      last_delivered_mail.text.should include("#{Rubytime::CONFIG[:site_url]}")
    end
  end

end