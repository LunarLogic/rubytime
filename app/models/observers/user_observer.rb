class UserObserver
  include DataMapper::Observer

  observe User

  before :save do
    #not using updated_at because of user versioning
    #for sake of simplicity we want this property to be called the same in User and UserVersion
    #if it was called updated_at, it would be overwritten when saving the UserVersion object
    pending_version_attributes[:modified_at] = modified_at || created_at
    self.modified_at = DateTime.now
  end

  UserVersion.properties.each do |property|
    attr_name = property.name
    next if attr_name == :version_id
    before "#{attr_name}=".to_sym do
      unless (value = property.get(self)).nil? || pending_version_attributes.key?(attr_name)
        pending_version_attributes[attr_name] = value
      end
    end
  end

  after :update do
    other_attributes = attributes.reject{ |k,v| !UserVersion.properties.named?(k)}
    UserVersion.create(other_attributes.merge(pending_version_attributes))
    pending_version_attributes.clear
  end

  after :create do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:welcome, :to => self.email, :from => Rubytime::CONFIG[:mail_from], :subject => "Welcome to Rubytime!")
  end
  
  after :generate_password_reset_token do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:password_reset_link, :to => self.email,
      :from => Rubytime::CONFIG[:mail_from], :subject => "Password reset request from Rubytime")
  end
  
end
