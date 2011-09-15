require "spec_helper"

describe ActivitiesController do
  describe "routing" do      
    it "should match /activities to Activities#index" do
      get("/activities").should route_to("controller" => "activities", "action" => "index")
    end
    
    it "should match /project/x/activities to Activities#index with :project_id set" do
      project = Project.generate
      get("/projects/#{project.id}/activities").
        should route_to("controller" => "activities",
                        "action" => "index",
                        "project_id" => project.id.to_s)
    end

    it "should match /users/3/calendar to Activites#calendar with user_id = 3" do
      get("/users/3/calendar").should route_to("controller" => "activities",
                                               "action" => "calendar",
                                               "user_id" => "3")
    end

    it "should match /projects/4/calendar to Activites#calendar with project_id = 4" do
      get("/projects/4/calendar").should route_to("controller" => "activities",
                                                  "action" => "calendar",
                                                  "project_id" => "4")
    end

    it "should dispatch /activities/day to Activities#day" do
      get("/activities/day").should route_to("controller" => "activities",
                                             "action" => "day")
    end
  end
end
