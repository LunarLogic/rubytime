def ensure_rate_exists(args)
  return unless args[:project] && args[:role] && args[:takes_effect_at]
  params = { :project => args[:project], :role => args[:role] }
  existing = HourlyRate.first(params.merge(:takes_effect_at.lte => args[:takes_effect_at]))
  existing || Factory.create(:hourly_rate, params.merge(:takes_effect_at => Date.parse("2000-01-01")))
end

Factory.sequence(:user_name) { |n| "User RubyTime User ##{n}" }
Factory.sequence(:user_login) { |n| "user_#{n}" }
Factory.sequence(:user_email) { |n| "user_#{n}@rubytime.org" }
Factory.define(:user, :class => 'User') do |u|
  u.name { Factory.next(:user_name) }
  u.login { Factory.next(:user_login) }
  u.email { Factory.next(:user_email) }
  u.password 'asdf1234'
  u.password_confirmation { |u| u.password }
end

Factory.define(:employee, :parent => :user, :class => Employee) do |u|
  u.association :role
end

Factory.define(:admin, :parent => :employee) do |u|
  u.admin true
end

Factory.define(:client_user, :parent => :user, :class => ClientUser) do |u|
  u.association :client
end

Factory.sequence(:client_name) { |n| "Client ##{n}" }
Factory.sequence(:client_description) { |n| "The description of client ##{n}" }
Factory.sequence(:client_email) { |n| "client_#{n}@company.com" }
Factory.define(:client, :class => Client) do |u|
  u.name { Factory.next(:client_name) }
  u.description { Factory.next(:client_description) }
  u.email { Factory.next(:client_email) }
end

Factory.sequence(:role_name) { |n| "role_#{n}" }
Factory.define(:role, :class => Role) do |r|
  r.name { Factory.next(:role_name) }
end

Factory.sequence(:project_name) { |n| "Project ##{n}" }
Factory.define(:project, :class => Project) do |p|
  p.name { Factory.next(:project_name) }
  p.association :client
end

Factory.sequence(:comment) { |n| "Activity comment ##{n}" }
Factory.define(:activity, :class => Activity) do |a|
  a.association :user, :factory => :employee
  a.association :project
  a.date { Date.today }
  a.minutes { 30 }
  a.comments { Factory.next(:comment) }
  a.after_build { |a| ensure_rate_exists(:project => a.project, :role => a.role_for_date, :takes_effect_at => a.date) }
end

Factory.sequence(:activity_type_name)
Factory.define(:activity_type) do |at|
  at.name { Factory.next(:activity_type_name) }
end

Factory.sequence(:activity_custom_property_name)
Factory.define(:activity_custom_property) do |acp|
  acp.name { Factory.next(:activity_custom_property_name) }
  acp.required false
  acp.show_as_column_in_tables true
end 

Factory.define(:activity_custom_property_value) do |acpv|
  acpv.association :activity
  acpv.association :activity_custom_property
  acpv.numeric_value 1.0
end

Factory.sequence(:invoice_number) { |n| "Invoice ##{n}" }
Factory.define(:invoice, :class => Invoice) do |i|
  i.name { Factory.next(:invoice_number) }
  i.association(:client, :factory => :client)
  i.association(:user, :factory => :employee)
end

Factory.define(:invoice_issued, :parent => :invoice) do |i|
  i.issued_at { Date.today }
end

Factory.define(:free_day, :class => FreeDay) do |fd|
  fd.user { |a| a.association(:employee) }
  fd.date { Date.today }
end

Factory.define(:hourly_rate, :class => HourlyRate) do |hr|
  hr.project { Project.generate }
  hr.role { Role.generate }
  hr.takes_effect_at { Date.today }
  hr.value { 1000 }
  hr.currency { Currency.pick_or_generate }
  hr.operation_author { Employee.first_or_generate }
end

Factory.define(:hourly_rate_log, :class => HourlyRateLog) do |hrl|
  hrl.operation_type 'update'
  hrl.operation_author { Employee.pick_or_generate }
  hrl.hourly_rate { HourlyRate.pick_or_generate }
end

Factory.define(:currency, :class => Currency) do |c|
  c.custom_sequence(:singular_name, 'aaaa') { |n| "currency #{n}" }
  c.custom_sequence(:plural_name, 'aaaa') { |n| "currency #{n}s" }
  c.prefix "P"
end
