group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mocha', :require => false
  gem 'shoulda', "3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'minitest', '~> 3.5', :platforms => :ruby_19
  gem 'minitest-spec-rails', :platforms => :ruby_19  # Drop in MiniTest::Spec support for Rails 3.
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'spork'
  gem 'spork-testunit', :platforms => :ruby_18
  gem "spork-minitest", "~> 1.0.0.beta2", :platforms => :ruby_19
end
