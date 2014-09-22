group :test do
  gem 'mocha', :require => false
  gem 'simplecov'
  gem 'spork-minitest'
  gem 'single_test'
  gem 'minitest', '~> 5.1'
#  gem 'minitest-spec-rails'
  gem 'ci_reporter', '>= 1.6.3', "< 2.0.0", :require => false
  gem 'capybara', '~> 2.0.0'
  # pinned for Ruby 1.8, selenium dependency
  gem 'rubyzip', '~> 0.9'
  gem 'database_cleaner', '0.9.1'
  gem 'launchy'
  gem 'spork'
  gem 'factory_girl_rails', '~> 1.2', :require => false
  gem 'oj'
  gem 'rubocop-checkstyle_formatter'
end
