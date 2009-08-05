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
      fx(:stefan).activities = [ Activity.gen(:project => fx(:bananas_first_project), :user => fx(:stefan), :date => Date.parse('2009-08-03')) ]
    end
    
    it 'should return true for days with activities' do
      fx(:stefan).has_activities_on?(Date.parse('2009-08-03')).should be_true
    end
    
    it 'should return false for days with no activities' do
      fx(:stefan).has_activities_on?(Date.parse('2009-08-04')).should be_false
    end
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

end
