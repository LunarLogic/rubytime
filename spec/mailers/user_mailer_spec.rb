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
  
  describe '#timesheet_summary' do
    it "includes dates range, days, projects and activities, site url" do
      deliver :timesheet_summary, {}, :user => @user, :dates_range => Date.parse('2009-08-10')..Date.parse('2009-08-14'), :url => Rubytime::CONFIG[:site_url],
        :activities_by_dates_and_projects => [
          [ Date.parse('2009-08-10'),
            [
              [ @project_AAA = Project.new(:name => 'Project AAA'),
                [ @activity_AAA2 = Activity.new(:minutes => 120, :comments => 'AAA 2 hours'),
                  @activity_AAA3 = Activity.new(:minutes => 180, :comments => 'AAA 3 hours')
                ]
              ],
              [ @project_BBB = Project.new(:name => 'Project BBB'),
                [ @activity_BBB4 = Activity.new(:minutes => 240, :comments => 'BBB 4 hours')
                ]
              ]
            ]
          ],
          [ Date.parse('2009-08-11'),
            []
          ],
          [ Date.parse('2009-08-13'),
            [
              [ @project_CCC = Project.new(:name => 'Project CCC'),
                [ @activity_CCC5 = Activity.new(:minutes => 300, :comments => 'CCC 5 hours')
                ]
              ]
            ]
          ]
        ]
        
      last_delivered_mail.text.should include("#{@user.name}")
      last_delivered_mail.text.should include("#{Date.parse('2009-08-10')..Date.parse('2009-08-14')}")
      last_delivered_mail.text.should include("On #{Date.parse('2009-08-10')}")
      last_delivered_mail.text.should include("On #{Date.parse('2009-08-11')}")
      last_delivered_mail.text.should include("On #{Date.parse('2009-08-13')}")
      last_delivered_mail.text.should_not include("On #{Date.parse('2009-08-12')}")
      last_delivered_mail.text.should_not include("On #{Date.parse('2009-08-14')}")
      
      last_delivered_mail.text.should include("#{@project_AAA.name}")
      last_delivered_mail.text.should include("#{@activity_AAA2.hours} #{@activity_AAA2.comments}")
      last_delivered_mail.text.should include("#{@activity_AAA3.hours} #{@activity_AAA3.comments}")
      last_delivered_mail.text.should include("#{@project_BBB.name}")
      last_delivered_mail.text.should include("#{@activity_BBB4.hours} #{@activity_BBB4.comments}")
      last_delivered_mail.text.should include("#{@project_CCC.name}")
      last_delivered_mail.text.should include("#{@activity_CCC5.hours} #{@activity_CCC5.comments}")

      last_delivered_mail.text.should include("#{Rubytime::CONFIG[:site_url]}")
    end
  end

end