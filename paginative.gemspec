$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paginative/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paginative"
  s.version     = Paginative::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Paginative."
  s.description = "TODO: Description of Paginative."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

  s.test_files = Dir["spec/**/*"]
end
