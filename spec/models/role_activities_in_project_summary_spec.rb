require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe RoleActivitiesInProjectSummary do
  
  context "without any activities" do
    before do
      @user = mock('user', :role => mock('role'))
      @summary = RoleActivitiesInProjectSummary.new( @user.role, [] )
    end
    
    it "should create the summary" do
      @summary.role.should               == @user.role
      @summary.non_billable_time.should  == 0
      @summary.billable_time.should      == 0
      @summary.price[fx(:euro  )].should == Money.new(0, fx(:euro  ))
      @summary.price[fx(:dollar)].should == Money.new(0, fx(:dollar))
    end
  end
  
  context "with some activities" do
    before do
      @user = mock('user', :role => mock('role'))
      @summary = RoleActivitiesInProjectSummary.new( @user.role,
        [ mock('activity', :user => @user, :duration => 1.hour             , :price => Money.new(20, fx(:euro  )) ),
          mock('activity', :user => @user, :duration => 1.hour + 20.minutes, :price => nil                    ),
          mock('activity', :user => @user, :duration =>          15.minutes, :price => Money.new( 7, fx(:dollar)) ),
          mock('activity', :user => @user, :duration =>          45.minutes, :price => nil                    ),
          mock('activity', :user => @user, :duration =>           5.minutes, :price => Money.new(11, fx(:euro  )) )
          ]
      )
    end
    
    it "should create the summary" do
      @summary.role.should               == @user.role
      @summary.non_billable_time.should  == 2.hours +  5.minutes
      @summary.billable_time.should      == 1.hour  + 20.minutes
      @summary.price[fx(:euro  )].should == Money.new(31, fx(:euro  ))
      @summary.price[fx(:dollar)].should == Money.new( 7, fx(:dollar))
    end
  end
  
  describe "#<<" do
    before do
      @user = mock('user', :role => mock('role'))
      @summary = RoleActivitiesInProjectSummary.new( @user.role, [] )
    end
    
    context "if called with activity of proper role" do
      before { @summary << mock('activity', :user => @user, :duration => 1.hour, :price => nil) }
      it "should add activity" do
        @summary.non_billable_time.should == 1.hour
      end
    end
    
    context "if called with activity of improper role" do
      it "should add activity" do
        lambda {
          @summary << mock('activity', :user => mock('another user', :role => mock('another role')), :duration => 1.hour, :price => nil)
        }.should raise_error(ArgumentError)
      end
    end
  end
  
end