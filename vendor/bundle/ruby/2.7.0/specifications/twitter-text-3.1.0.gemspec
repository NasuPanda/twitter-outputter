# -*- encoding: utf-8 -*-
# stub: twitter-text 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "twitter-text".freeze
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David LaMacchia".freeze, "Sudheer Guntupalli".freeze, "Kaushik Lakshmikanth".freeze, "Jose Antonio Marquez Russo".freeze, "Lee Adams".freeze, "Yoshimasa Niwa".freeze]
  s.date = "2020-03-31"
  s.description = "A gem that provides text handling for Twitter".freeze
  s.email = ["opensource@twitter.com".freeze]
  s.homepage = "http://twitter.com".freeze
  s.licenses = ["Apache 2.0".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Twitter text handling library".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_development_dependency(%q<multi_json>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.10.9"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<unf>.freeze, ["~> 0.1.0"])
    s.add_runtime_dependency(%q<idn-ruby>.freeze, [">= 0"])
  else
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.3"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.10.9"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<unf>.freeze, ["~> 0.1.0"])
    s.add_dependency(%q<idn-ruby>.freeze, [">= 0"])
  end
end
