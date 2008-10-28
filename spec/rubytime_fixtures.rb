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
          
          # Admin
          add_fixture(:employee, :admin, Employee.gen(:admin, :role => fx(:project_manager)))
          
          # Jola
          add_fixture(:employee, :jola, Employee.gen(:role => fx(:developer)))
          
          # Stefan
          add_fixture(:employee, :stefan, Employee.gen(:role => fx(:tester)))
          
          # Misio
          add_fixture(:employee, :misio, Employee.gen(:role => fx(:developer)))
          
          # Koza (also admin, issues invoices for clients)
          add_fixture(:employee, :koza, Employee.gen(:admin, :role => fx(:project_manager)))
          
          
          # === Generating clients
          
          # Orange client has many activities and many invoices (also issued)
          add_fixture(:client, :orange, Client.gen)
          
          add_fixture(:client, :apple, Client.gen)
          
          # Banana has no activities / invoices
          add_fixture(:client, :banana, Client.gen)
          
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
          
          # === Generating projects
          
          add_fixture(:project, :oranges_first_project, Project.gen(:client => fx( :orange)))
          add_fixture(:project, :oranges_second_project, Project.gen(:client => fx(:orange)))
          
          # Orange's inactive project with some invoiced activities
          add_fixture(:project, :oranges_inactive_project, Project.gen(:client => fx(:orange), :active => false))

          add_fixture(:project, :apples_first_project, Project.gen(:client => fx(:apple)))
          add_fixture(:project, :apples_second_project, Project.gen(:client => fx(:apple)))

          # Apple's inactive project with uninvoiced activities
          add_fixture(:project, :apples_inactive_project, Project.gen(:client => fx(:apple), :active => false))

          add_fixture(:project, :bananas_first_project, Project.gen(:client => fx(:banana)))
          add_fixture(:project, :bananas_second_project, Project.gen(:client => fx(:banana)))
          
          # === Generating invoices

          # not locked
          add_fixture(:invoice, :oranges_first_invoice, Invoice.gen(:client => fx(:orange), :user => fx(:koza)))
          
          # locked
          add_fixture(:invoice, :oranges_issued_invoice, Invoice.gen(:issued, :client => fx(:orange), :user => fx(:koza)))

          # === Generating activities
          
          # for Jola
          add_fixture(:activity, :jolas_activity1, Activity.gen(:project => fx(:oranges_first_project), :user => fx(:jola)))
          add_fixture(:activity, :jolas_invoiced_activity, Activity.gen(:project => fx(:oranges_first_project), 
                                                                        :user    => fx(:jola), 
                                                                        :invoice => fx(:oranges_first_invoice)))
          add_fixture(:activity, :jolas_locked_activity, Activity.gen(:project => fx(:oranges_first_project), 
                                                                        :user    => fx(:jola), 
                                                                        :invoice => fx(:oranges_issued_invoice)))
          

          
          # TODO: add some invoiced activities to oranges_inactive_project and 
          # uninvoiced activities to apples_inactive_project
        end
        
        def add_fixture(type, name, obj)
          @@fixtures[[type, name]] = obj
        end
        
        def get_fixture(*args)
          case args.size
          when 2
            object = @@fixtures[[args.first, args.last]]
            raise ArgumentError, "No fixture #{args.first}:#{args.last}" unless object
            object
          when 1
            objects = @@fixtures.select { |k,v| k.last == args.first }
            raise ArgumentError, "Multiple or no fixture with name #{args.first}" unless objects.size == 1
            objects.first.last
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
      end
    end
  end
end
