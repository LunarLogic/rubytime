require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do
  it "should generate password" do
    user = User.new
    user.password.should be_nil
    user.password_confirmation.should be_nil
    user.generate_password!
    user.password.should_not be_nil
    user.password_confirmation.should_not be_nil
  end
  
  it "should validate login format" do
    ["stefan)(*&^%$)", "foo bar", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "][;'/.,?><!@#}{}]"].each do |login|
      user = Employee.make(:login => login)
      user.save.should(be_false)
      user.errors.on(:login).should_not(be_nil)
    end
    
    %w(maciej-lotkowski stefan_ks bob kiszka123 12foo123).each do |login|
      Employee.make(:login => login, :role => fx(:developer)).save.should be_true
    end
  end

  it "shouldn't authenticate inactive user" do
    password = "awsumpass"
    login = "awsum-stefan"
    employee = Employee.make(:active => false, :login => login, :password => password, 
      :password_confirmation => password, :role => fx(:developer))
    employee.save.should be_true
    User.authenticate(login, password).should be_nil
  end

  it "should send welcome email to new user" do
    block_should(change(Merb::Mailer.deliveries, :size).by(1)) do
      Employee.gen(:role => fx(:developer))
    end
    Merb::Mailer.deliveries.last.text.should include("welcome") 
  end

  it "should generate a password reset token with expiration time" do
    user = fx(:jola)

    user.generate_password_reset_token.should be(true)
    user.password_reset_token_exp.should <= DateTime.now+Rubytime::PASSWORD_RESET_LINK_EXP_TIME
  end

  it "should send email with password reset link to user requesting it" do
    block_should(change(Merb::Mailer.deliveries, :size).by(1)) do
      user = fx(:jola)
      user.generate_password_reset_token
    end
    Merb::Mailer.deliveries.last.text.should include("reset password") 
  end

  it "should required password" do
    Employee.new.password_required?.should be_true
    user = Employee.get(Employee.gen(:role => fx(:developer)).id) #prevent from keeping password_confirmation set
    user.password_required?.should be_false
    user.password = "kiszka"
    user.password_required?.should be_true
    user = ClientUser.gen
    user.password_confirmation = "aaaaaa"
    user.password_required?.should be_true
  end

  it "shouldn't allow to delete it if there is a related invoice or activity" do
    block_should_not(change(User, :count)) do
      fx(:jola).destroy
    end
  end

  # in april 2009 were 22 working days
  it "should have 18 days without activity besides two days with activities, vacation days and weekends in april 2009" do
    fx(:stefan).indefinite_activities("2009-04-01", "2009-04-30").size.should == 22
    Activity.make(:project => fx(:oranges_first_project), :user => fx(:stefan), :date => Date.parse("2009-04-17")).save.should be_true
    Activity.make(:project => fx(:oranges_first_project), :user => fx(:stefan), :date => Date.parse("2009-04-15")).save.should be_true
    FreeDay.make(:user => fx(:stefan), :date => Date.parse("2009-04-21")).save.should be_true
    FreeDay.make(:user => fx(:stefan), :date => Date.parse("2009-04-22")).save.should be_true
    fx(:stefan).indefinite_activities("2009-04-01", "2009-04-30").size.should == 18
  end
  
  describe '#has_activities_on?' do
    before do
      fx(:stefan).activities.all.destroy!
      fx(:stefan).activities << Activity.gen(:project => fx(:bananas_first_project), :user => fx(:stefan), :date => Date.parse('2009-08-03'))
    end
    
    it 'should return true for days with activities' do
      fx(:stefan).has_activities_on?(Date.parse('2009-08-03')).should be_true
    end
    
    it 'should return false for days with no activities' do
      fx(:stefan).has_activities_on?(Date.parse('2009-08-04')).should be_false
    end
  end
  
  describe "#can_manage_financial_data?" do
    context "for admin user" do
      before { @user = User.new :admin => true }
      it { @user.can_manage_financial_data?.should == true }
    end
    context "for non-admin user" do
      before { @user = User.new :admin => false }
      it { @user.can_manage_financial_data?.should == false }
    end
  end

  describe "with_activities" do
    it "should include users which have added activities" do
      user = Employee.generate!
      Activity.generate! :user => user
      User.with_activities.should include(user)
    end

    it "should not include users which haven't added any activities" do
      user = Employee.generate!
      User.with_activities.should_not include(user)
    end

    it "should not include duplicate entries" do
      user = Employee.generate!
      2.times { Activity.generate! :user => user }
      User.with_activities.find_all { |u| u == user }.length.should == 1
    end
  end

  describe "with_activities_for_client" do
    it "should include users which have added activities for any of client's projects" do
      user = Employee.generate!
      client = Client.generate!
      project = Project.generate! :client => client
      Activity.generate! :user => user, :project => project
      User.with_activities_for_client(client).should include(user)
    end

    it "should not include users which haven't added any activities for any of client's projects" do
      user = Employee.generate!
      client = Client.generate!
      client2 = Client.generate!
      project = Project.generate! :client => client
      project2 = Project.generate! :client => client2
      Activity.generate! :user => user, :project => project2
      User.with_activities_for_client(client).should_not include(user)
    end

    it "should not include duplicate entries" do
      user = Employee.generate!
      client = Client.generate!
      project = Project.generate! :client => client
      project2 = Project.generate! :client => client
      Activity.generate! :user => user, :project => project
      Activity.generate! :user => user, :project => project2
      User.with_activities_for_client(client).should == [user]
    end
  end
end

describe "admin" do
  it "should return a proper user_type" do
    Employee.new(:admin => true).user_type.should == :admin
  end
end

describe Employee do
  it "should have calendar viewable by himself and admin" do
    employee = fx(:jola)
    employee.calendar_viewable?(employee).should be_true
    employee.calendar_viewable?(fx(:admin)).should be_true
    employee.calendar_viewable?(fx(:stefan)).should be_false
  end

  it "should create user" do
    lambda { Employee.make(:role => fx(:developer)).save.should be_true }.should change(Employee, :count).by(1)
  end
  
  it "should be an employee" do
    Employee.make.is_employee?.should be_true
  end
  
  it "shouldn't be admin" do
    Employee.new.is_admin?.should be_false 
  end

  it "should return a proper user_type" do
    Employee.new.user_type.should == :employee
  end

  it "shouldn't create user without name" do
    user = Employee.gen :name => nil
    user.save.should be_false
    user.errors.on(:name).should_not be_nil
  end
  
  it "should be editable by himself and admin" do
    user = fx(:jola)
    user.editable_by?(user).should be_true
    user.editable_by?(fx(:admin)).should be_true
    user.editable_by?(fx(:stefan)).should be_false
    user.editable_by?(fx(:orange_user1)).should be_false
  end
  
  it "should create user with given password and authenticate" do 
    pass = "kiszka123"
    login = "stefan13"
    
    user = Employee.make :login => login, :password => pass, :password_confirmation => pass, :role => fx(:developer)
    user.save.should be_true
    User.authenticate(login, pass).should == User.get(user.id)
  end

  it "should return nil for authentication with bad login or password" do
    User.authenticate("bad-login", "bad-password").should be_nil
  end
  
  it "should be admin" do
    Employee.make(:admin).is_admin?.should be_true
  end
  
  describe ".send_timesheet_naggers_for" do
    it "should send emails to employees that have no activities on given day" do
      Activity.all.destroy!
      Activity.make(:user => fx(:stefan), :date => Date.parse('2009-08-03')).save!
      Activity.make(:user => fx(:koza), :date => Date.parse('2009-08-03')).save!
      
      block_should change(Merb::Mailer.deliveries, :size).by(3) do
        Employee.send_timesheet_naggers_for(Date.parse('2009-08-03'))
      end
    end
  end
  
  describe ".send_timesheet_reporter_for" do
    it "should send email to given address with a list of the employees who have no activities on given day" do
      Activity.all.destroy!
      Activity.make(:user => fx(:stefan), :date => Date.parse('2009-08-03')).save!
      Activity.make(:user => fx(:koza), :date => Date.parse('2009-08-03')).save!
      
      block_should change(Merb::Mailer.deliveries, :size).by(1) do
        Employee.send_timesheet_reporter_for(Date.parse('2009-08-03'), 'email@localhost')
      end
      
      Merb::Mailer.deliveries.last.text.should include(fx(:admin).name)
      Merb::Mailer.deliveries.last.text.should include(fx(:jola).name) 
      Merb::Mailer.deliveries.last.text.should include(fx(:misio).name) 
    end
  end
  
  describe "#activities_by_dates_and_projects" do
    it "should return nested tables dates -> projects -> activities" do
      fx(:oranges_first_project).update_attributes :name => 'BBB'
      fx(:oranges_second_project).update_attributes :name => 'AAA'
      
      fx(:stefan).activities.destroy!
      fx(:stefan).activities << @activity1 = Activity.gen(:user => fx(:stefan), :project => fx(:oranges_first_project), :date => Date.parse('2009-08-10'))
      fx(:stefan).activities << @activity2 = Activity.gen(:user => fx(:stefan), :project => fx(:oranges_second_project), :date => Date.parse('2009-08-12'))
      fx(:stefan).activities << @activity3 = Activity.gen(:user => fx(:stefan), :project => fx(:oranges_first_project), :date => Date.parse('2009-08-12'))
      fx(:stefan).activities << @activity4 = Activity.gen(:user => fx(:stefan), :project => fx(:oranges_second_project), :date => Date.parse('2009-08-12'))
      
      fx(:stefan).activities_by_dates_and_projects(Date.parse('2009-08-10')..Date.parse('2009-08-12')).should == [
        [ Date.parse('2009-08-10'),
          [
            [ fx(:oranges_first_project) , [@activity1] ]
          ]
        ],
        [ Date.parse('2009-08-11'),
          [
          ]
        ],
        [ Date.parse('2009-08-12'),
          [
            [ fx(:oranges_second_project), [@activity2, @activity4] ],
            [ fx(:oranges_first_project),  [@activity3] ]
          ]
        ]
      ]
    end
  end
  
  describe "#send_timesheet_summary_for" do
    it "should create UserMailer and dispatch and deliver the message" do
      @user = fx(:stefan)
      @dates_range = Date.parse('2009-08-10')..Date.parse('2009-08-12')
      @user.stub!(:activities_by_dates_and_projects => @activities_by_dates_and_projects = mock('activities_by_dates_and_projects'))
      
      @user_mailer = mock('UserMailer')
      @user_mailer.should_receive(:dispatch_and_deliver).with(:timesheet_summary, :to => @user.email, :from => Rubytime::CONFIG[:mail_from], :subject => "RubyTime timesheet summary for #{@dates_range}")
      UserMailer.should_receive(:new).with(:user => @user, :dates_range => @dates_range, :activities_by_dates_and_projects => @activities_by_dates_and_projects ).and_return(@user_mailer)
      
      @user.send_timesheet_summary_for(@dates_range)
    end
  end
  
  describe "#can_manage_financial_data?" do
    context "for admin user" do
      before { @employee = Employee.new :admin => true }
      it { @employee.can_manage_financial_data?.should == true }
    end
    context "for non-admin user" do
      before { @employee = Employee.new :admin => false }
      
      context "that has role that can manage financial data" do
        before { @employee.role = Role.new(:can_manage_financial_data => true) }
        it { @employee.can_manage_financial_data?.should == true }
      end
      
      context "that has role that cannot manage financial data" do
        before { @employee.role = Role.new(:can_manage_financial_data => false) }
        it { @employee.can_manage_financial_data?.should == false }
      end
    end
  end
  
end

describe ClientUser do

  it "shouldn't be admin" do
    ClientUser.new.is_admin?.should be_false 
  end
  
  it "shouldn't be an employee" do
    ClientUser.make.is_employee?.should be_false
  end

  it "should have client" do
    client_user = ClientUser.make(:client => nil)
    client_user.save.should be_false
    client_user.errors.on(:client).should_not be_nil
  end

  it "should return a proper user_type" do
    ClientUser.new.user_type.should == :client_user
  end

end
