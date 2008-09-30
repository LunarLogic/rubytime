# User.fixture {{
#   :name => (name = /\w{3,}/.gen),
#   :login => name,
#   :email => "#{name}@kiszonka.com",
#   :password => (password = /\w{6,}/.gen), 
#   :password_confirmation => password
# }}

User.fixture {{
  :name => (name = /\w{3,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password
}}
