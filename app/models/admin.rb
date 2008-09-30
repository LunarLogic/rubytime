require Merb.root / 'lib/rubytime/config'

class Admin < User
  def self.create_account
    admin = Admin.new :name => Rubytime::Config::ADMIN[:name],
                      :login => Rubytime::Config::ADMIN[:login],
                      :email => Rubytime::Config::ADMIN[:email],
                      :password => Rubytime::Config::ADMIN[:password],
                      :password_confirmation => Rubytime::Config::ADMIN[:password]
    admin.save
  end
end