require 'foreman/util'
include Foreman::Util

unless Foreman::Application.config.secret_token
  tmp = Rails.root.join("tmp")
  Dir.mkdir(tmp) unless File.exist? tmp

  token_store = Rails.root.join("tmp", "secret_token")
  token = File.read(token_store) if File.exist? token_store
  unless token
    token = secure_token
    File.open(token_store, "w", 0600) { |f| f.write(token) }
  end
  Foreman::Application.config.secret_token = token
### Please note that you should wait to set secret_key_base until you have 100% of your userbase on Rails 4.x and are reasonably sure you will not need to rollback to Rails 3.x.
# Foreman::Application.config.secret_key_base = 'TODO TO PULL FROM secret_token.rb'
end
