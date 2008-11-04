require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserMailer do
  include MailControllerTestHelper
  
  before :each do
    clear_mail_deliveries
    @user = Employee.gen(:password_reset_token => "1234asdjfggh3f2e44rtsdfhg")
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
end