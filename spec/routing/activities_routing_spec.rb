require "spec_helper"

describe ActivitiesController do
  describe "routing" do      
    it "should should match /activities to Activities#index" do
      get("/activities").should route_to("controller" => "activities", "action" => "index")
    end
    
    it "should should match /project/x/activities to Activities#index with :project_id set" do
      project = Project.generate
      get("/projects/#{project.id}/activities").
        should route_to("controller" => "activities",
                        "action" => "index",
                        "project_id" => project.id.to_s)
    end       
  end
end
