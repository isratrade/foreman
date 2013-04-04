group :test do
  gem 'mocha', :require => false
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'minitest-spec-rails-tu-shim', :platforms => :ruby_18
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'spork'
  gem "spork-minitest", "~> 1.0.0.beta2", :platforms => :ruby_19
  gem "turn"
end
