def random_date(start_date, end_date)
  start_date + (rand * (end_date - start_date)).to_i
end

def ensure_rate_exists(args)
  params = { :project => args[:project], :role => args[:role] }
  existing = HourlyRate.first(params.merge(:takes_effect_at.lte => args[:takes_effect_at]))
  existing || Factory.create(:hourly_rate, params.merge(:takes_effect_at => Date.parse("2000-01-01")))
end


Factory.define(:employee, :class => Employee) do |u|
  u.sequence(:name) { |n| "RubyTime User ##{n}" }
  u.sequence(:login) { |n| "user_#{n}" }
  u.sequence(:email) { |n| "user_#{n}@rubytime.org" }
  u.password 'asdf1234'
  u.password_confirmation { |u| u.password }
  u.association :role
end

Factory.define(:admin, :parent => :employee) do |u|
  u.admin true
end

Factory.define(:client_user, :parent => :employee, :class => ClientUser) do |u|
  u.association :client
end

Factory.define(:client, :class => Client) do |u|
  u.sequence(:name) { |n| "Client ##{n}" }
  u.sequence(:description) { |n| "The decription of client ##{n}" }
  u.sequence(:email) { |n| "client_#{n}@company.com" }
end

Factory.define(:role, :class => Role) do |r|
  r.sequence(:name) { |n| "role_#{n}" }
end

Factory.define(:project, :class => Project) do |p|
  p.sequence(:name) { |n| "Project ##{n}" }
  p.association :client
end

Factory.define(:activity, :class => Activity) do |a|
  a.user { Employee.pick }
  a.project { Project.pick }
  a.date { random_date(Date.today - 15, Date.today - 5) }
  a.minutes { 30 + rand * (23 * 60) }
  a.sequence(:comments) { |n| "Activity comment ##{n}" }
  a.after_build { |a| ensure_rate_exists(:project => a.project, :role => a.user.role, :takes_effect_at => a.date) }
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
  hr.project { Project.pick }
  hr.role { |a| Role.pick }
  hr.takes_effect_at { random_date(Date.today - 365 * 2, Date.today) }
  hr.value { 20 + (rand * 10000).to_i / 100 }
  hr.currency { Currency.pick }
  hr.operation_author { Employee.first }
end

Factory.define(:hourly_rate_log, :class => HourlyRateLog) do |hrl|
  hrl.operation_type 'update'
  hrl.operation_author { Employee.pick }
  hrl.hourly_rate { HourlyRate.pick }
end

Factory.define(:currency, :class => Currency) do |c|
  c.sequence(:singular_name) { |n| "currency_#{n}" }
  c.sequence(:plural_name) { |n| "currency_#{n}s" }
  c.prefix "P"
end
