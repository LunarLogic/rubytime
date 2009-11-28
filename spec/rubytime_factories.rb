def random_date(start_date, end_date)
  start_date + (rand * (end_date - start_date)).to_i
end

Factory.define(:employee, :class => Employee) do |u|
  u.sequence(:name) { |n| "RubyTime User ##{n}" }
  u.sequence(:login) { |n| "user_#{n}" }
  u.sequence(:email) { |n| "user_#{n}@rubytime.org" }
  u.password 'asdf1234'
  u.password_confirmation { |u| u.password }
  u.role {|r| r.association(:role) }
end

Factory.define(:admin, :parent => :employee) do |u|
  u.admin true
end

Factory.define(:client_user, :parent => :employee, :class => ClientUser) do |u|
  u.client { |a| a.association(:client) }
end

Factory.define(:client, :class => Client) do |u|
  u.sequence(:name) { |n| "Cient ##{n}" }
  u.sequence(:description) { |n| "The decription of client ##{n}" }
  u.sequence(:email) { |n| "client_#{n}@company.com" }
end

Factory.define(:role, :class => Role) do |r|
  r.sequence(:name) { |n| "role_#{n}" }
end

Factory.define(:project, :class => Project) do |p|
  p.sequence(:name) { |n| "Project ##{n}" }
  p.client { |a| a.association(:client) }
end

Factory.define(:activity, :class => Activity) do |p|
  p.user { |a| a.association(:employee) }
  p.project { |a| a.association(:project) }
  p.date { random_date(Date.today - 15, Date.today - 5) }
  p.minutes { 30 + rand * (23 * 60) }
  p.sequence(:comments) { |n| "Activity comment ##{n}" }
end

Factory.define(:invoice, :class => Invoice) do |i|
  i.sequence(:name) { |n| "Invoice ##{n}" }
  i.client { |a| a.association(:client) }
  i.user { |a| a.association(:employee) }
end

Factory.define(:invoice_issued, :parent => :invoice) do |i|
  i.issued_at { random_date(Date.today - 180, Date.today) }
end

Factory.define(:free_day, :class => FreeDay) do |fd|
  fd.user { |a| a.association(:user) }
  fd.date { random_date(Date.today - 15, Date.today - 5) }
end

Factory.define(:hourly_rate, :class => HourlyRate) do |hr|
  hr.project { |a| a.association(:project) }
  hr.role { |a| a.association(:role) }
  hr.takes_effect_at { random_date(Date.today - 365 * 2, Date.today) }
  hr.value { 20 + (rand * 10000).to_i / 100 }
  hr.currency { |a| a.association(:currency) }
  hr.operation_author { Employee.first }
end

Factory.define(:hourly_rate_log, :class => HourlyRateLog) do |hrl|
  hrl.operation_type 'update'
  hrl.operation_author { |a| a.association(:employee) }
  hrl.hourly_rate { |a| a.association(:hourly_rate) }
end

Factory.define(:currency, :class => Currency) do |c|
  c.sequence(:singular_name) { |n| "currency_#{n}" }
  c.sequence(:plural_name) { |n| "currency_#{n}s" }
  c.prefix "P"
end
