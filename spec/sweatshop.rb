def random_date(start_date, end_date)
  start_date + (rand * (end_date - start_date)).to_i
end

User.fixture {{
  :name => (name = /\w{3,15}/.gen),
  :login => name,
  :email => "#{name}@kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password
}}

Client.fixture {{
  :name => (name = /\w{4,12}/.gen),
  :login => name,
  :email => "#{name}@klyjencka_kiszonka.com",
  :password => (password = /\w{6,20}/.gen), 
  :password_confirmation => password
}}

Project.fixture {{
  :name => /\w{6,10}/.gen,
  :client => Client.gen
}}

Activity.fixture {{
  :user => User.gen,
  :project => Project.gen,
  :date => random_date(Date.today - 15, Date.today - 5),
  :minutes => 30 + rand * 100,
  :comments => /(\w{3,8}\s){1,5}/.gen
}}

Invoice.fixture {{
  :name => /200\d-\d{2}-\d{2}/.gen,
  :client => Client.gen
}}
