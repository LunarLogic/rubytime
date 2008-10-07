desc "add testing users"
namespace :rubytime do
  task :kickstart => :merb_env do
    
    # admin
    if Admin.count == 0
      puts "creating admin account"
      Admin.create_account
    end
    
    pass = "tt1234"

    # developers
    1.upto(3) do |i|
      unless User.first(:login => "dev#{i}")
        puts "creating developer account: dev#{i} with pass \"#{pass}\""
        User.create(:name => "Developer #{i}", :login => "dev#{i}", :password => pass, :password_confirmation => pass, :email => "dev#{i}@tt666.com")
      end
    end

    # cleints
    ["apple", "orange", "banana"].each do |name|
      unless Client.first(:login => name)
        puts "creating client account: #{name} with pass \"#{pass}\""
        Client.create(:name => name.camel_case, :login => name, :password => pass, :password_confirmation => pass, :email => "#{name}@tt666.com")
      end
    end

    # projects    
    ["apple", "orange", "banana"].each do |client_name|
      project_name = "Big project for #{client_name.camel_case}"
      unless Project.first(:name => project_name)
        puts "creating project: #{project_name}"
        client = Client.first(:login => client_name)
        Project.create(:client => client, :name => project_name)
      end
    end
    
  end
end
