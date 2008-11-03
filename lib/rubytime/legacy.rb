module Rubytime
  module Legacy
    def self.import_data
      Merb::Mailer.delivery_method = :test_send
      DataMapper.auto_migrate!
      
      # Redefine properties
      
      Client.class_eval do
        properties(:legacy).clear
        repository(:legacy) do
          property :id,           DataMapper::Types::Serial
          property :name,         String
          property :description,  DataMapper::Types::Text
          property :active,       DataMapper::Types::Boolean, :field => "is_inactive"
        end
      end
      
      Project.class_eval do
        properties(:legacy).clear
        repository(:legacy) do
          property :id,           DataMapper::Types::Serial
          property :name,         String
          property :description,  DataMapper::Types::Text
          property :client_id,    Integer
          property :active,       DataMapper::Types::Boolean, :field => "is_inactive"
          property :created_at,   DateTime
        end
      end

      User.class_eval do
        properties(:legacy).clear
        repository(:legacy) do
          property :id,            DataMapper::Types::Serial
          property :name,          String 
          property :login,         String
          property :email,         String
          property :active,        DataMapper::Types::Boolean, :field => "is_inactive"
          property :role_id,       Integer
          property :created_at,    DateTime
          belongs_to :role
        end
      end

      Activity.class_eval do
        properties(:legacy).clear
        repository(:legacy) do
          property :id,          DataMapper::Types::Serial
          property :comments,    DataMapper::Types::Text
          property :date,        Date
          property :minutes,     Integer
          property :project_id,  Integer
          property :user_id,     Integer
          property :invoice_id,  Integer
          property :created_at,  DateTime
        end
      end
      
      _ClientLogin = Class.new
      _ClientLogin.class_eval do
        include DataMapper::Resource
        storage_names[:legacy] = "clients_logins"
        property :id,          DataMapper::Types::Serial
        property :login,       String
        property :client_id,   Integer
      end

      # Copy data
      
      #Client.copy(:legacy, :default)
      puts "importing clients"
      Client.all(:repository => repository(:legacy)).each do |client|
        Client.create(client.attributes.merge(:active => !client.active))
      end
      fix_serial(Client)
      
      puts "importing projects"
      Project.all(:repository => repository(:legacy)).each do |project|
        Project.create(project.attributes.merge(:active => !project.active))
      end
      fix_serial(Project)
      
      puts "importing users"
      User.all(:repository => repository(:legacy), :id.gt => 0).each do |user|
        puts "user: #{user.name}, role: #{user.role.name}"
        role = Role.first(:name => user.role.name) || Role.create(:name => user.role.name)
        e = Employee.create(user.attributes.merge(:active => !user.active, :password => "foobar", 
                                                  :password_confirmation => "foobar", :role_id => role.id ))
        unless e.errors.empty?
          p e
          p e.errors
        end
      end
      
      puts "importing client users"
      _ClientLogin.all(:repository => repository(:legacy)).each do |user|
        e = ClientUser.create(:login => user.login, :name => user.login, :password => "foobar", :password_confirmation => "foobar", 
                              :client_id => user.client_id, :email => "#{user.login}@fixthisemail.com")
        unless e.errors.empty?
          p e
          p e.errors
        end
      end
      
      fix_serial(User)
      
      puts "importing activities"
      Activity.all(:repository => repository(:legacy)).each do |activity|
        Activity.create(activity.attributes)
      end
      fix_serial(Activity)
      
      puts "importing invoices"
      Invoice.all(:repository => repository(:legacy)).each do |invoice|
        Invoice.create(invoice.attributes)
      end
      fix_serial(Invoice)
    end
    
    def self.fix_serial(klass)
      last = klass.first(:order => [:id.desc]) or return
      table_name = klass.to_s.downcase.pluralize
      puts "fixing #{klass}"
      
      if repository.adapter.class.to_s =~ /Mysql/
        repository.adapter.execute("alter table #{table_name} AUTO_INCREMENT=#{last.id + 1}")
      elsif repository.adapter.class.to_s =~ /Postgres/
        model.repository.adapter.query("select setval('#{table_name}_id_seq', #{last.id + 1});")
      end
    end
  end
end