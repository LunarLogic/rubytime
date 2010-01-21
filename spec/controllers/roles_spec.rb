require 'spec_helper'

describe Roles do
  it "shouldn't show any action for guest, employee and client's user" do
    [:index, :create, :edit, :update, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Roles, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(Roles, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Roles, action) }
    end
  end
  
  describe "#index" do
    it "should show list of roles" do
      as(:admin).dispatch_to(Roles, :index).should be_successful
    end
  end
  
  describe "#create" do
    it "should create new role successfully and redirect to index" do
      block_should(change(Role, :count)) do
        controller = as(:admin).dispatch_to(Roles, :create, { :role => { :name => "Mastah" }})
        controller.should redirect_to(resource(:roles))
      end
    end
  end
  
  describe "#edit" do
    it "should show role edit form" do
      role = Role.gen
      as(:admin).dispatch_to(Roles, :edit, :id => role.id).should be_successful
    end
  end
  
  describe "#update" do
    before do
      @role = Role.gen(:name => 'OriginalName')
      @response = as(:admin).dispatch_to(Roles, :update, { :id => @role.id, :role => { :can_manage_financial_data => true }})
    end
    
    it "should update the role" do
      Role.get(@role.id).can_manage_financial_data.should == true
    end
    
    it "should redirect to #index" do
      @response.should redirect_to(resource(:roles))
    end
  end

  describe "#destroy" do
    it "should delete role" do
      role = Role.gen
      block_should(change(Role, :count)) do
        as(:admin).dispatch_to(Roles, :destroy, :id => role.id)
      end
    end
  end
end