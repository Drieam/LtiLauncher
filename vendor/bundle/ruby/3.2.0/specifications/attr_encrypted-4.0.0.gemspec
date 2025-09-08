# -*- encoding: utf-8 -*-
# stub: attr_encrypted 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "attr_encrypted".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sean Huber".freeze, "S. Brent Faulkner".freeze, "William Monk".freeze, "Stephen Aghaulor".freeze]
  s.date = "2023-04-06"
  s.description = "Generates attr_accessors that encrypt and decrypt attributes transparently".freeze
  s.email = ["seah@shuber.io".freeze, "sbfaulkner@gmail.com".freeze, "billy.monk@gmail.com".freeze, "saghaulor@gmail.com".freeze]
  s.homepage = "http://github.com/attr-encrypted/attr_encrypted".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\n\n\nWARNING: Using `#encrypted_attributes` is no longer supported. Instead, use `#attr_encrypted_encrypted_attributes` to avoid\n  collision with Active Record 7 native encryption.\n\n\n".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Encrypt and decrypt attributes".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<encryptor>.freeze, ["~> 3.0.0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 2.0.0"])
  s.add_development_dependency(%q<actionpack>.freeze, [">= 2.0.0"])
  s.add_development_dependency(%q<datamapper>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<sequel>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["= 1.5.4"])
  s.add_development_dependency(%q<dm-sqlite-adapter>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
end
