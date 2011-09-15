require 'spec_helper'

describe ActivityCustomPropertiesController do

  it "shouldn't show any action for guest, employee or client's user" do
    [[:index, :get], [:create, :post], [:edit, :get], [:update, :put], [:destroy, :delete]].
      each do |action, method|
      login(:guest) and send(method, action, :id => 1).status.should == 403
      login(:employee) and send(method, action, :id => 1).status.should == 403
      login(:client) and send(method, action, :id => 1).status.should == 403
    end
  end

  context "as admin" do
    login(:admin)

    describe "GET 'index'" do
      it "should show a list of all custom properties" do
        ActivityCustomProperty.all.destroy!
        properties = (0..2).map { ActivityCustomProperty.generate }
        get(:index)
        response.should be_successful
        assigns[:new_activity_custom_property].should be_an(ActivityCustomProperty)
        assigns[:activity_custom_properties].should == properties
      end
    end

    describe "POST 'create'" do
      it "should create a new custom property successfully and redirect to index" do
        block_should(change(ActivityCustomProperty, :count)) do
          post(:create, {:activity_custom_property => {
                   :name => "Kill count",
                   :unit => "Enemies",
                   :required => false}})
          response.should redirect_to(activity_custom_properties_path)
          ActivityCustomProperty.last.name.should == "Kill count"
        end
      end
    end

    describe "GET 'edit'" do
      it "should show property edit form" do
        property = ActivityCustomProperty.generate
        get(:edit, :id => property.id).should be_successful
      end
    end

    describe "PUT 'update'" do
      it "should update the property" do
        property = ActivityCustomProperty.generate :name => 'OriginalName'
        put(:update, {
              :id => property.id,
              :activity_custom_property => {
                :name => 'NewName'
              }
            })
        response.should redirect_to(activity_custom_properties_path)
        ActivityCustomProperty.get(property.id).name.should == 'NewName'
      end
    end

    describe "DELETE 'destroy'" do
      it "should delete the property" do
        property = ActivityCustomProperty.generate
        block_should(change(ActivityCustomProperty, :count).by(-1)) do
          delete(:destroy, :id => property.id)
        end
      end
    end
  end
end
