group :test do
  gem 'mocha', :require => false
  gem 'minitest'
  gem 'single_test'
  gem 'rake'
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'spork'
  gem 'spork-testunit'
end
