require 'spec_helper'

describe ActivityCustomProperties do

  it "shouldn't show any action for guest, employee or client's user" do
    [:index, :create, :edit, :update, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(ActivityCustomProperties, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(ActivityCustomProperties, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(ActivityCustomProperties, action) }
    end
  end

  describe "#index" do
    it "should show a list of all custom properties" do
      ActivityCustomProperty.all.destroy!
      properties = (0..2).map { ActivityCustomProperty.generate }
      response = as(:admin).dispatch_to(ActivityCustomProperties, :index)
      response.should be_successful
      response.instance_variable_get("@new_activity_custom_property").should be_an(ActivityCustomProperty)
      response.instance_variable_get("@activity_custom_properties").should == properties
    end
  end

  describe "#create" do
    it "should create a new custom property successfully and redirect to index" do
      block_should(change(ActivityCustomProperty, :count)) do
        response = as(:admin).dispatch_to(ActivityCustomProperties, :create, {
          :activity_custom_property => {
            :name => "Kill count",
            :unit => "Enemies",
            :required => false
          }
        })
        response.should redirect_to(resource(:activity_custom_properties))
        ActivityCustomProperty.last.name.should == "Kill count"
      end
    end
  end

  describe "#edit" do
    it "should show property edit form" do
      property = ActivityCustomProperty.generate
      as(:admin).dispatch_to(ActivityCustomProperties, :edit, :id => property.id).should be_successful
    end
  end

  describe "#update" do
    it "should update the property" do
      property = ActivityCustomProperty.generate :name => 'OriginalName'
      response = as(:admin).dispatch_to(ActivityCustomProperties, :update, {
        :id => property.id,
        :activity_custom_property => {
          :name => 'NewName'
        }
      })
      response.should redirect_to(resource(:activity_custom_properties))
      ActivityCustomProperty.get(property.id).name.should == 'NewName'
    end
  end

  describe "#destroy" do
    it "should delete the property" do
      property = ActivityCustomProperty.generate
      block_should(change(ActivityCustomProperty, :count).by(-1)) do
        as(:admin).dispatch_to(ActivityCustomProperties, :destroy, :id => property.id)
      end
    end
  end

end
