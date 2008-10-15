require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserMailer do
  include MailControllerTestHelper
  
  before :each do
    clear_mail_deliveries
    @user = Employee.gen
  end
    
  it "includes welcome phrase, login, password and site url in welcome mail" do
    deliver :welcome, {}, :user => @user, :url => Rubytime::CONFIG[:site_url]
    last_delivered_mail.text.should include("#{@user.name}, welcome")
    last_delivered_mail.text.should include("login: #{@user.login}")
    last_delivered_mail.text.should include("password: #{@user.password}")
    last_delivered_mail.text.should include(Rubytime::CONFIG[:site_url])
  end
end