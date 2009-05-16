desc "add testing users"
namespace :rubytime do
  task :kickstart => :merb_env do
    
    Merb::Mailer.delivery_method = :test_send

    developer = Role.first(:name => "Developer") || Role.create(:name => "Developer")
    pm = Role.first(:name => "Project Manager") || Role.create(:name => "Project Manager")
    tester = Role.first(:name => "Tester") || Role.create(:name => "Tester")
    
    pass = "password"

    # developers
    1.upto(3) do |i|
      unless Employee.first(:login => "dev#{i}")
        puts "creating developer account: dev#{i} with pass \"#{pass}\""
        Employee.create(:name => "Developer #{i}", :login => "dev#{i}", :password => pass, :password_confirmation => pass, :email => "dev#{i}@tt666.com", :role => developer)
      end
    end
    
    # admin
    unless Employee.first(:login => "admin")
      puts "creating admin account: admin with pass \"#{pass}\""
      Employee.create(:name => "Admin Adminiusz", :login => "admin", :password => pass, :password_confirmation => pass, :email => "admin@tt666.com", :role => developer, :admin => true)
    end
    
    # clients
    ["Apple", "Orange", "Banana"].each do |name|
      unless Client.first(:name => name)
        puts "creating client #{name}"
        Client.create(:name => name)
      end
    end

    # client users
    ["Apple", "Orange", "Banana"].each do |name|
      client = Client.first(:name => name)
      unless ClientUser.first(:client_id => client.id)
        puts "creating client user's account: #{name.downcase} with pass \"#{pass}\""
        ClientUser.create(:name => "#{name}'s user", :login => name.downcase, :password => pass, :password_confirmation => pass, :email => "#{name}@tt666.com", :client => client)
      end
    end
    
    # projects    
    ["Apple", "Orange", "Banana"].each do |client_name|
      project_name = "Big project for #{client_name}"
      unless Project.first(:name => project_name)
        puts "creating project: #{project_name}"
        client = Client.first(:name => client_name)
        Project.create(:client => client, :name => project_name)
      end
    end
    
  end
end
