def random_date(start_date, end_date)
  start_date + (rand * (end_date - start_date)).to_i
end

include DataMapper::Sweatshop::Unique

Employee.fixture {{
  :name => (name = unique { /\w{6,20}/.gen }),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :role => Role.pick
}}

Employee.fixture(:admin) {{
  :name => (name = unique { /\w{6,20}/.gen }),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password,
  :admin => true,
  :role => Role.pick
}}

ClientUser.fixture {{
  :name => (name = unique { /\w{6,20}/.gen }),
  :login => name,
  :email => "#{name}@company.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password
}}

Client.fixture {{
  :name => /\w{5,20}/.gen
}}

Role.fixture {{
  :name => /\w{3,10}/.gen
}}

Project.fixture {{
  :name => /\w{6,10}/.gen
}}

Activity.fixture {
  project = Project.pick
  {
  :user => Employee.pick,
  :project => project,
  :activity_type => project.activity_types.first,
  :date => random_date(Date.today - 15, Date.today - 5),
  :minutes => 30 + rand * (23 * 60),
  :comments => /(\w{3,8}\s\d{6}\s){1,5}/.gen
}}

Invoice.fixture {{
  :name => /200\d-\d{2}-\d{2}-\w{6,15}/.gen,
  :client => Client.pick,
  :user => Employee.pick
}}

Invoice.fixture(:issued) {{
  :name => /200\d-\d{2}-\d{2}/.gen,
  :client => Client.pick,
  :user => Employee.pick,
  :issued_at => random_date(Date.today - 180, Date.today)
}}

FreeDay.fixture {{
  :user => Employee.pick,
  :date => random_date(Date.today - 15, Date.today - 5),
}}

ActivityType.fixture {{
  :name => /\w{6,10}/.gen
}}
