require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Sessions do
  include ControllerSpecsHelper
  
  it "should route to Sessions#new from '/login'" do
     request_to("/login") do |params|
       params[:controller].should == "Sessions"
       params[:action].should == "new"
     end
   end

   it "should route to Sessions#create from '/login' by post" do
     request_to("/login", :post) do |params|
       params[:controller].should  == "Sessions"
       params[:action].should      == "create"
     end
   end

   it "should have route to Sessions#destroy from '/logout' by delete" do
     request_to("/logout", :delete) do |params|
       params[:controller].should == "Sessions"
       params[:action].should    == "destroy"
     end
   end

   it "should route to Sessions#destroy from '/logout' by get" do
     request_to("/logout") do |params|
       params[:controller].should == "Sessions" 
       params[:action].should     == "destroy"
     end
   end

   it 'should try to login with wrong data' do
     controller = dispatch_to(Sessions, :create, {:login => 'not-existing', :password => 'wrong-password'})
     controller.should redirect_to("/login")
   end
   
   it "should redirect admin to activities" do
     Admin.create_account.should(be_true) if Admin.count == 0
     dispatch_to_as_admin(Sessions, :index).should redirect_to(url(:activities))
   end
   
   it "should redirect employee to new activity" do
     Employee.gen if Employee.count == 0
     dispatch_to_as_employee(Sessions, :index).should redirect_to(url(:new_activity))
   end

   it "should redirect client to activities" do
     ClientUser.gen if ClientUser.count == 0
     dispatch_to_as_client(Sessions, :index).should redirect_to(url(:activities))
   end

   it 'should login correctly' do
     Admin.create_account if Admin.count == 0
     controller = dispatch_to(Sessions, :create, {
       :login => Rubytime::Config::ADMIN[:login], :password => Rubytime::Config::ADMIN[:password] })
     controller.session[:user_id].should_not be_nil
     controller.flash[:notice].should_not be_nil
     controller.should redirect_to("/")
   end
   
   it 'should logout correctly' do
     user = User.gen
     user.save!
     
     controller = dispatch_to(Sessions, :destroy) do |controller| 
       controller.session[:user_id] = user.id 
       controller.session[:user_id].should_not be_nil
     end
     controller.session[:user_id].should be_nil
     controller.flash[:notice].should_not be_nil
   end
end