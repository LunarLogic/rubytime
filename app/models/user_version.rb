# Poor man's implementation of dm-is-versioned, which apparently does not work with STI
# at the time of this writing

class UserVersion
  include DataMapper::Resource

  #some of user's properties were excluded from versioning
  property :id,                            Integer#, :key => true
  property :name,                          String, :required => true
  property :type,                          String, :index => true
  property :login,                         String, :required => true, :index => true, :format => /^[\w_\.-]{3,20}$/
  property :email,                         String, :required => true, :format => :email_address
  property :admin,                         Boolean, :required => true, :default => false
  property :role_id,                       Integer, :index => true
  property :client_id,                     Integer, :index => true
  property :created_at,                    DateTime
  property :modified_at,                   DateTime#, :key => true #not updated_at on purpose
  property :date_format,                   Enum[*::Rubytime::DATE_FORMAT_NAMES], :default => :european, :required => true
  property :recent_days_on_list,           Enum[*::Rubytime::RECENT_DAYS_ON_LIST], :default => ::Rubytime::RECENT_DAYS_ON_LIST.first,
    :required => true
  property :remind_by_email,               Boolean, :required => true, :default => false
  property :version_id,                    Serial

  belongs_to :role
end
