# Poor man's implementation of dm-is-versioned, which apparently does not work with STI
# at the time of this writing

class UserVersion
  include DataMapper::Resource

  # some of user's properties were excluded from versioning
  # id = user's id, not version's id
  property :id,                            Integer
  property :name,                          String
  property :type,                          String
  property :login,                         String
  property :email,                         String
  property :admin,                         Boolean
  property :role_id,                       Integer
  property :client_id,                     Integer
  property :created_at,                    DateTime
  property :modified_at,                   DateTime # not updated_at on purpose
  property :date_format,                   Integer
  property :recent_days_on_list,           Integer
  property :remind_by_email,               Boolean
  property :version_id,                    Serial

  default_scope(:default).update(:order => [:version_id])

  belongs_to :role
end
