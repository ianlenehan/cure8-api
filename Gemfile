source 'https://rubygems.org'
ruby '2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# gem 'devise'
gem 'active_model_serializers'
gem 'faraday', '~> 0.16.2'

gem 'twilio-ruby', '~> 5.25.0'
gem 'jwt'
gem 'metainspector'
gem 'httparty'
gem 'foreman', '~> 0.82.0'
gem 'graphql'
gem "graphiql-rails"
gem 'json', '~> 1.8.6'
gem 'firebase_id_token', '~> 2.3.1'
gem 'whenever', require: false
gem 'geocoder'
gem 'will_paginate', '~> 3.1.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
# gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Use RSpec for specs
  gem 'rspec-rails', '>= 3.5.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Use Factory Girl for generating random test data
  gem 'factory_bot'
  gem 'pry'
  gem 'pry-nav'
  gem 'faker'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
