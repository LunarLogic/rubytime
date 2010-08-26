require 'spec_helper'

describe Estimates do

  it "shouldn't show any action for guest, employee and client's user" do
    [:index, :update_all].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Estimates, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(Estimates, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Estimates, action) }
    end
  end

  describe "#index" do

    context "with :project_id param of existing project" do
      before { @project = Project.generate }

      it "should be succesful" do
        as(:admin).dispatch_to(Estimates, :index, :project_id => @project.id).should be_successful
      end

      it "should render :index template" do
        as(:admin).dispatch_to(Estimates, :index, :project_id => @project.id) do |controller|
          controller.should_receive(:render).with(:index, { :template => nil })
        end
      end
    end

    context "without :project_id" do

      it "should be succesful" do
        as(:admin).dispatch_to(Estimates, :index).should be_successful
      end

      it "should render :projects template" do
        as(:admin).dispatch_to(Estimates, :index) do |controller|
          controller.should_receive(:render).with(:projects)
        end
      end
    end

  end

  describe "#update_all" do

    context "with :project_id param of existing project" do
      before { @project = Project.generate }

      context "with successful estimates update" do
        before do
          Project.stub(:get => @project)
          @project.stub(:update_estimates => true)
        end

        it "should redirect to url(:estimates)" do
          as(:admin).dispatch_to(Estimates, :update_all, { :project_id => @project.id, :project => { :activity_types => mock } }).should redirect(resource(:estimates))
        end
      end

      context "with failed estimates update" do
        before do
          @project.stub(:update_estimates => false)
          Project.stub(:get => @project)
        end

        it "should be succesful" do
          as(:admin).dispatch_to(Estimates, :update_all, { :project_id => @project.id, :project => { :activity_types => mock } }).should be_successful
        end

        it "should render :index template" do
          as(:admin).dispatch_to(Estimates, :update_all, { :project_id => @project.id, :project => { :activity_types => mock } }) do |controller|
            controller.should_receive(:render).with(:index)
          end
        end
      end
    end
  end

end
