# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-sweatshop}
  s.version = "0.9.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Burkert"]
  s.date = %q{2008-11-17}
  s.description = %q{DataMapper plugin for building pseudo random models}
  s.email = ["ben@benburkert.com"]
  s.extra_rdoc_files = ["README.textile", "LICENSE", "TODO"]
  s.files = ["LICENSE", "Manifest.txt", "README.textile", "Rakefile", "TODO", "lib/dm-sweatshop.rb", "lib/dm-sweatshop/sweatshop.rb", "lib/dm-sweatshop/model.rb", "lib/dm-sweatshop/version.rb", "lib/dm-sweatshop/unique.rb", "spec/dm-sweatshop/model_spec.rb", "spec/dm-sweatshop/sweatshop_spec.rb", "spec/dm-sweatshop/unique_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sam/dm-more/tree/master/dm-Sweatshop}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{DataMapper plugin for building pseudo random models}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["= 0.9.7"])
      s.add_runtime_dependency(%q<randexp>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<dm-core>, ["= 0.9.7"])
      s.add_dependency(%q<randexp>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<dm-core>, ["= 0.9.7"])
    s.add_dependency(%q<randexp>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
