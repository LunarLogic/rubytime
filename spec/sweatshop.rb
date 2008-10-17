def random_date(start_date, end_date)
  start_date + (rand * (end_date - start_date)).to_i
end

Employee.fixture {{
  :name => (name = /\w{6,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :role => Role.gen
}}

Employee.fixture(:admin) {{
  :name => (name = /\w{6,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :admin => true,
  :role => Role.gen
}}


Employee.fixture(:with_activities) {{
  :name => (name = /\w{6,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :admin => true,
  :role => Role.gen,
  :activities => (5..10).of { Activity.gen(:without_user) }
}}

ClientUser.fixture(:without_client) {{
  :name => (name = /\w{3,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password
}}

ClientUser.fixture {{
  :name => (name = /\w{3,15}/.gen),
  :login => name,
  :email => "#{name}@company.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :client => Client.gen
}}

Client.fixture {{
  :name => /\w{5,20}/.gen
}}

Client.fixture(:with_invoices) {{
  :name => /\w{5,20}/.gen,
  :invoices => (5..10).of { Invoice.gen(:without_client) }
}}

Role.fixture {{
  :name => /\w{3,10}/.gen
}}

Project.fixture {{
  :name => /\w{6,10}/.gen,
  :client => Client.gen
}}

Activity.fixture {{
  :user => Employee.gen,
  :project => Project.gen,
  :date => random_date(Date.today - 15, Date.today - 5),
  :minutes => 30 + rand * 100,
  :comments => /(\w{3,8}\s){1,5}/.gen
}}

Activity.fixture(:without_user) {{
  :project => Project.gen, 
  :date => random_date(Date.today - 15, Date.today - 5),
  :minutes => 30 + rand * 100,
  :comments => /(\w{3,8}\s){1,5}/.gen
}}

Invoice.fixture {{
  :name => /200\d-\d{2}-\d{2}/.gen,
  :client => Client.gen,
  :user => Employee.gen
}}

Invoice.fixture(:without_client) {{
  :name => /200\d-\d{2}-\d{2}/.gen,
  :user => Employee.gen
}}
