class UserObserver
  include DataMapper::Observer

  observe User

  before :save do
    self.version(DateTime.now) unless new?  # force creation of first version if it should exist but it doesn't

    # not using updated_at because of user versioning
    # for sake of simplicity we want this property to be called the same in User and UserVersion
    # if it was called updated_at, it would be overwritten when saving the UserVersion object
    self.modified_at = DateTime.now
    @role_changed = self.attribute_dirty?(:role_id)
  end

  after :save do
    save_new_version if self.versions.count == 0 || @role_changed
  end

  after :create do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:welcome, :to => self.email, :from => Rubytime::CONFIG[:mail_from], :subject => "Welcome to Rubytime!")
  end

  before :destroy do
    versions.all.destroy!
  end

  after :generate_password_reset_token do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:password_reset_link, :to => self.email,
      :from => Rubytime::CONFIG[:mail_from], :subject => "Password reset request from Rubytime")
  end
  
end
