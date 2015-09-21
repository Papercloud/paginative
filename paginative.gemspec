$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paginative/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paginative"
  s.version     = Paginative::VERSION
  s.authors     = ["Isaac Norman"]
  s.email       = ["idn@papercloud.com.au"]
  s.homepage    = "http://www.github.com/RustComet/paginative"
  s.summary     = "A new way to paginate your Rails API"
  s.description = "After spending a lot of time screwing around with orphaned objects and every other problem that pagination causes, this is the solution"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.2"
  s.add_dependency "geocoder", "~> 1.1.9"

  s.add_development_dependency "sqlite3", "~> 1.3.9"
  s.add_development_dependency 'rspec-rails', "~> 2.14.2"
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'capybara', "~> 2.2.1"
  s.add_development_dependency 'factory_girl_rails', "~> 4.4.1"
  s.add_development_dependency 'database_cleaner', "~> 1.2.0"
  s.add_development_dependency 'awesome_print', "~> 1.2.0"
  s.add_development_dependency 'appraisal'

  s.test_files = Dir["spec/**/*"]
end
