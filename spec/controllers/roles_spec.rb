require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Roles do
  it "shouldn't show any action for guest, employee and client's user" do
    [:index, :create, :destroy].each do |action|
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

  describe "#destroy" do
    it "should delete role" do
      role = Role.gen
      block_should(change(Role, :count)) do
        as(:admin).dispatch_to(Roles, :destroy, :id => role.id)
      end
    end
  end
end