# frozen_string_literal: true

ruby '2.7'

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Admin interface
gem 'administrate', '~> 0.12.0'
# JSON Web Tokens
gem 'jwt', '~> 2.2.1'
# HTTP/REST API client library.
gem 'faraday_middleware', '~> 0.13.1'
# Cache HTTP responses
gem 'faraday-http-cache', '~> 2.0'
# Generates attr_accessors that encrypt and decrypt attributes transparently
gem 'attr_encrypted', '~> 3.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Testing framework
  gem 'rspec-rails', '~> 4.0.0.beta3'
  # Helpers to test rails controllers
  gem 'rails-controller-testing'
  # RSpec matchers
  gem 'shoulda-matchers'
  # Replacement for fixtures
  gem 'factory_bot_rails'
  # Generate fake data
  gem 'ffaker'
  # Clean the database between specs
  gem 'database_cleaner'
  # Stubbing of web requests
  gem 'webmock'
  # Travel in time in the specs
  gem 'timecop'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Ruby linters
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # Static security analysis
  gem 'brakeman'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# #####
# # FOR SINATRA APP
# #####
#
# # Sinatra for the webapp
# gem 'sinatra', require: false
# gem 'sinatra-contrib', require: false
# # gem 'activesupport', '~> 6.0.1', require: false
# gem 'faraday_middleware', require: false
# gem 'jwt', require: false
#
# # Automated reloading rack development server
# # Usage: shotgun -p 4567 app.rb
# gem 'shotgun', group: :development
# # gem 'byebug', group: :development
