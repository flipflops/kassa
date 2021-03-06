source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
ruby '2.1.0'
gem 'rails', '4.1.4'

#Database
gem 'pg'

#Server
gem 'puma'

#Authentication
gem 'devise'

#Views
gem 'slim-rails'

#JSON API
gem 'jbuilder'
gem 'multi_json'
gem 'yajl-ruby'

#Assets
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier'
gem 'coffee-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'angularjs-rails'
gem 'gravtastic'
gem 'lodash-rails'

#Monitoring
gem 'newrelic_rpm'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :mri_21, :rbx]
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'teaspoon'
  gem 'guard'
  gem 'guard-teaspoon', :git => 'git://github.com/modeset/guard-teaspoon.git'
  gem 'guard-rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'json_spec'
  gem 'shoulda-matchers'
  gem 'ffaker'
  gem "codeclimate-test-reporter", :require => nil
  gem 'simplecov'
end

