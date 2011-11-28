RSpec::Matchers.define :have_errors_on do |attr|
  match do |resource|
    resource.valid?
    not resource.errors.on(attr).nil?
  end
end

RSpec::Matchers.define :be_forbidden do
  match do |response|
    response.status == 403
  end
end

RSpec::Matchers.define :be_not_found do
  match do |response|
    response.status == 404
  end
end

RSpec::Matchers.define :be_not_acceptable do
  match do |response|
    response.status == 406
  end
end
