# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE
require File.expand_path('../config/settings', FOREMAN_GEMFILE)
require File.expand_path('../lib/regexp_extensions', FOREMAN_GEMFILE)

source 'https://rubygems.org'

gem 'rails', '3.2.21'
gem 'json', '~> 1.5'
gem 'rest-client', '~> 1.6.0', :require => 'rest_client'
gem 'audited-activerecord', '3.0.0'
gem 'will_paginate', '~> 3.0'
gem 'ancestry', '~> 2.0'
gem 'scoped_search', '~> 2.7'
gem 'ldap_fluff', '~> 0.3'
gem 'apipie-rails', '~> 0.2.5'
gem 'rabl', '~> 0.11'
gem 'oauth', '~> 0.4'
gem 'deep_cloneable', '~> 2.0'
gem 'foreigner', '~> 1.4'
gem 'validates_lengths_from_database',  '~> 0.2'
gem 'friendly_id', '~> 4.0'
#gem 'secure_headers', '~> 1.3'
gem 'safemode', '~> 1.2'
gem 'fast_gettext', '0.9.0'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'i18n', '~> 0.6.4'
gem 'turbolinks', '~> 2.5'
#gem 'secure_headers', '~> 1.3.3'

gem 'rack-cors', :require => 'rack/cors'
#gem 'fusor', :git => 'https://github.com/fusor/fusor.git'
gem 'fusor_ui', :path => '../fusor_ui'
#gem 'foreman_api_v3', :path => '../foreman_api_v3'

#gem 'katello', :git => 'https://github.com/Katello/katello.git', :branch => 'KATELLO-2.0'
#gem 'katello', :path => '../katello'
<<<<<<< upstream/develop
=======


if RUBY_VERSION =~ /^1\.8/
  # Older version of safemode for Ruby 1.8, as the latest causes regexp overflows (#2100)
  gem 'safemode', '~> 1.0.2'
  gem 'ruby_parser', '>= 2.3.1', '< 3.0'

  # Used in fog, rbovirt etc.  1.6.0 breaks Ruby 1.8 compatibility.
  gem 'nokogiri', '~> 1.5.0'

  # 10.2.0 breaks Ruby 1.8 compatibility
  gem 'rake', '< 10.2.0'
else
  # Newer version of safemode contains fixes for Ruby 1.9
  gem 'safemode', '~> 1.2.1'
  gem 'ruby_parser', '~> 3.0.0'
end
>>>>>>> HEAD~3

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
