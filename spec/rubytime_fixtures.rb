module Rubytime
  module Test
    module Fixtures
      @@fixtures = {}
      
      class << self
      
        def prepare
          
          # === Generating roles
          
          add_fixture(:role, :developer, Role.gen(:name => "Developer"))
          add_fixture(:role, :project_manager, Role.gen(:name => "Project Manager"))
          add_fixture(:role, :tester, Role.gen(:name => "Tester"))
          
          # === Generating users
          
          # Admin (also project manager)
          add_fixture(:employee, :admin, Employee.gen(:admin, :role => fx(:project_manager)))
          
          # Jola (main developer)
          add_fixture(:employee, :jola, Employee.gen(:role => fx(:developer)))
          
          # Stefan (tester)
          add_fixture(:employee, :stefan, Employee.gen(:role => fx(:tester)))
          
          # Misio (dev)
          add_fixture(:employee, :misio, Employee.gen(:role => fx(:developer)))
          
          # Koza (also admin, issues invoices for clients)
          add_fixture(:employee, :koza, Employee.gen(:admin, :role => fx(:project_manager)))
          
          
          # === Generating clients
          
          # Orange client has many activities and many invoices (also issued)
          add_fixture(:client, :orange, Client.gen)
          
          add_fixture(:client, :apple, Client.gen)
          
          add_fixture(:client, :banana, Client.gen)
          
          # Peach has no activities / invoices
          add_fixture(:client, :peach, Client.gen)
          
          # Old, inactive client
          add_fixture(:client, :old_client, Client.gen(:active => false))
          add_fixture(:client, :another_old_client, Client.gen(:active => false))
          
          # === Generating client users
          
          add_fixture(:client_user, :orange_user1, ClientUser.gen(:client => fx(:orange)))
          add_fixture(:client_user, :orange_user2, ClientUser.gen(:client => fx(:orange)))

          add_fixture(:client_user, :apple_user1, ClientUser.gen(:client => fx(:apple)))
          add_fixture(:client_user, :apple_user2, ClientUser.gen(:client => fx(:apple)))

          add_fixture(:client_user, :banana_user1, ClientUser.gen(:client => fx(:banana)))
          add_fixture(:client_user, :banana_user2, ClientUser.gen(:client => fx(:banana)))
          
          add_fixture(:client_user, :peach_user1, ClientUser.gen(:client => fx(:peach)))
          add_fixture(:client_user, :peach_user2, ClientUser.gen(:client => fx(:peach)))
          
          # === Generating activity types
          
          add_fixture(:activity_type, :design,             ActivityType.gen(:name => "design"))
          add_fixture(:activity_type, :graphic_design,     ActivityType.gen(:name => "graphic design",     :parent => fx(:design)))
          add_fixture(:activity_type, :interaction_design, ActivityType.gen(:name => "interaction design", :parent => fx(:design)))

          add_fixture(:activity_type, :coding,             ActivityType.gen(:name => "coding"))

          add_fixture(:activity_type, :testing,            ActivityType.gen(:name => "testing"))
          add_fixture(:activity_type, :hallway_testing,    ActivityType.gen(:name => "hallway testing", :parent => fx(:testing)))
          add_fixture(:activity_type, :crash_testing,      ActivityType.gen(:name => "crash testing",   :parent => fx(:testing)))
          
          # === Generating projects

          # Orange
          
          add_fixture(:project, :oranges_first_project, Project.gen(:client => fx( :orange)))
          add_fixture(:project, :oranges_second_project, Project.gen(:client => fx(:orange)))
          # Orange's inactive project with some invoiced activities
          add_fixture(:project, :oranges_inactive_project, Project.gen(:client => fx(:orange), :active => false))

          # Apple
          
          add_fixture(:project, :apples_first_project, Project.gen(:client => fx(:apple)))
          add_fixture(:project, :apples_second_project, Project.gen(:client => fx(:apple)))
          # Apple's inactive project with uninvoiced activities
          add_fixture(:project, :apples_inactive_project, Project.gen(:client => fx(:apple), :active => false))
          
          # Banana
          
          add_fixture(:project, :bananas_first_project, Project.gen(:client => fx(:banana)))
          add_fixture(:project, :bananas_second_project, Project.gen(:client => fx(:banana)))
          
          # Peach
          add_fixture(:project, :peachs_first_project, Project.gen(:client => fx(:peach)))
          
          # === Generating invoices

          # not locked
          add_fixture(:invoice, :oranges_first_invoice, Invoice.gen(:client => fx(:orange), :user => fx(:koza)))
          
          # locked
          add_fixture(:invoice, :oranges_issued_invoice, Invoice.gen(:issued, :client => fx(:orange), :user => fx(:koza)))

          # === Assigning activity types
          
          fx(:oranges_first_project).activity_type_projects.create(:activity_type => fx(:coding))
          
          fx(:oranges_second_project).activity_type_projects.create(:activity_type => fx(:design))
          fx(:oranges_second_project).activity_type_projects.create(:activity_type => fx(:graphic_design))
          fx(:oranges_second_project).activity_type_projects.create(:activity_type => fx(:interaction_design))
          fx(:oranges_second_project).activity_type_projects.create(:activity_type => fx(:testing))
          fx(:oranges_second_project).activity_type_projects.create(:activity_type => fx(:crash_testing))
          
          fx(:apples_first_project).activity_type_projects.create(:activity_type => fx(:coding))
          fx(:apples_first_project).activity_type_projects.create(:activity_type => fx(:testing))
          fx(:apples_first_project).activity_type_projects.create(:activity_type => fx(:hallway_testing))
          fx(:apples_first_project).activity_type_projects.create(:activity_type => fx(:crash_testing))
          
          fx(:apples_second_project).activity_type_projects.create(:activity_type => fx(:coding))
          
          fx(:bananas_first_project).activity_type_projects.create(:activity_type => fx(:coding))

          # === Generating activities
          
          # -- Orange
          
          # by Jola (total 8 active)
          add_fixture(:activity, :jolas_activity1, Activity.gen(:project => fx(:oranges_first_project), :user => fx(:jola), :activity_type => fx(:coding)))
          add_fixture(:activity, :jolas_invoiced_activity, Activity.gen(:project => fx(:oranges_first_project), 
                                                                        :user    => fx(:jola), 
                                                                        :activity_type => fx(:coding), 
                                                                        :invoice => fx(:oranges_first_invoice)))
          add_fixture(:activity, :jolas_locked_activity, Activity.gen(:project => fx(:oranges_first_project), 
                                                                      :user    => fx(:jola), 
                                                                      :activity_type => fx(:coding), 
                                                                      :invoice => fx(:oranges_issued_invoice)))
          add_fixture(:activity, :jolas_another_locked_activity, Activity.gen(:project => fx(:oranges_first_project), 
                                                                              :user    => fx(:jola), 
                                                                              :activity_type => fx(:coding), 
                                                                              :invoice => fx(:oranges_issued_invoice)))
          # anonymous fixtures
          4.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_second_project), :user => fx(:jola), :activity_type => fx(:graphic_design))) }
          4.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_inactive_project), :user => fx(:jola), :activity_type => nil)) }

          # by Stefan (total 6 active)
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_first_project), :user => fx(:stefan), :activity_type => fx(:coding))) }
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_second_project), :user => fx(:stefan), :activity_type => fx(:crash_testing))) }
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_inactive_project), :user => fx(:stefan), :activity_type => nil)) }

          # by Misio (total 4 active) 
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_first_project), :user => fx(:misio), :activity_type => fx(:coding))) }
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_second_project), :user => fx(:misio), :activity_type => fx(:graphic_design))) }
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:oranges_inactive_project), :user => fx(:misio), :activity_type => nil)) }
          
          # -- Apple
          
          # by Jola (total 8 active)
          4.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_first_project), :user => fx(:jola), :activity_type => fx(:coding))) }
          4.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_second_project), :user => fx(:jola), :activity_type => fx(:coding))) }
          4.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_inactive_project), :user => fx(:jola), :activity_type => nil)) }

          # by Stefan (total 6 active)
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_first_project), :user => fx(:stefan), :activity_type => fx(:crash_testing))) }
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_second_project), :user => fx(:stefan), :activity_type => fx(:coding))) }
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_inactive_project), :user => fx(:stefan), :activity_type => nil)) }

          # by Misio (total 4 active)
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_first_project), :user => fx(:misio), :activity_type => fx(:coding))) }
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_second_project), :user => fx(:misio), :activity_type => fx(:coding))) }
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:apples_inactive_project), :user => fx(:misio), :activity_type => nil)) }
          
          # -- Banana
          
          # by Jola (total 3)
          3.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:bananas_first_project), :user => fx(:jola), :activity_type => fx(:coding))) }

          # by Stefan (total 2)
          2.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:bananas_first_project), :user => fx(:stefan), :activity_type => fx(:coding))) }

          # by Misio (total 1)
          1.times { add_fixture(:activity, nil, Activity.gen(:project => fx(:bananas_first_project), :user => fx(:misio), :activity_type => fx(:coding))) }
          
          
          # TODO: add some invoiced activities to oranges_inactive_project and 
          # uninvoiced activities to apples_inactive_project
        end
        
        def add_fixture(type, name, obj)
          raise ArgumentError, "#{obj.class} object not saved, errors: #{obj.errors.inspect}" if obj.new_record?
          @@fixtures[[type, name]] = obj
        end
        
        def get_fixture(*args)
          case args.size
          when 2
            object = @@fixtures[[args.first, args.last]]
            raise ArgumentError, "No fixture #{args.first}:#{args.last}" unless object
            object.reload
          when 1
            objects = @@fixtures.select { |k,v| k.last == args.first }
            raise ArgumentError, "Multiple or no fixture with name #{args.first}" unless objects.size == 1
            objects.first.last.reload
          else
            raise ArgumentError, "Wrong number of arguments"
          end
        end
        
        def fx(*args)
          get_fixture(*args)
        end
        
      end # class << self
      
      module FixturesHelper
        def fx(*args)
          Fixtures::get_fixture(*args)
        end
      end # FixturesHelper
    end # Fixtures
  end # Test
end # Rubytime
