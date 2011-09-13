Spec::Matchers.define :have_errors_on do |attr|
  match do |resource|
    resource.valid?
    not resource.errors.on(attr).nil?
  end
end
