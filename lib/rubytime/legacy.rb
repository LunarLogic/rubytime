module Rubytime
  module Legacy
    def self.import_data
      DataMapper.auto_migrate!
      
      # redefine properties
      Client.class_eval do
        properties(:rt2).clear
        repository(:rt2) do
          property :id,           DataMapper::Types::Serial
          property :name,         String, :nullable => false
          property :description,  DataMapper::Types::Text
          property :active,       DataMapper::Types::Boolean, :field => "is_inactive"
        end
      end
      
      Project.class_eval do
        properties(:rt2).clear
        repository(:rt2) do
          property :id,           DataMapper::Types::Serial
          property :name,         String, :nullable => false, :unique => true
          property :description,  DataMapper::Types::Text
          property :client_id,    Integer, :nullable => false
          property :active,       DataMapper::Types::Boolean, :field => "is_inactive"
          property :created_at,   DateTime
        end
      end
      
      # copy data
      #Client.copy(:rt2, :default)
      
      # invert active flag
      Client.all(:repository => repository(:rt2)).each do |client|
        Client.create(client.attributes.merge(:active => !client.active))
      end
      
      Project.all(:repository => repository(:rt2)).each do |project|
        Project.create(project.attributes.merge(:active => !project.active))
      end
      
      fix_serial(Client, 'clients')
      fix_serial(Project, 'projects')
    end
    
    def self.fix_serial(model, table_name)
      last = model.first(:order => [:id.desc])
      
      # postgres
      model.repository.adapter.query("select setval('#{table_name}_id_seq', #{last.id + 1});")
      
      # mysql
      #Client.repository.adapter.execute("alter table clients AUTO_INCREMENT=#{last_client.id + 1}")
    end
  end
end