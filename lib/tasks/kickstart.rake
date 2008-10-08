desc "add testing users"
namespace :rubytime do
  task :kickstart => :merb_env do
    
    developer = Role.first(:name => "Developer")
    developer = Role.create(:name => "Developer") unless developer
    
    pass = "tt1234"

    # developers
    1.upto(3) do |i|
      unless Employee.first(:login => "dev#{i}")
        puts "creating developer account: dev#{i} with pass \"#{pass}\""
        Employee.create(:name => "Developer #{i}", :login => "dev#{i}", :password => pass, :password_confirmation => pass, :email => "dev#{i}@tt666.com", :role => developer)
      end
    end

    # cleints
    ["Apple", "Orange", "Banana"].each do |name|
      unless Client.first(:name => name)
        puts "creating client and account: #{name} with pass \"#{pass}\""
        Client.create(:name => name)
        #ClientUser.create, :login => name, :password => pass, :password_confirmation => pass, :email => "#{name}@tt666.com")
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
