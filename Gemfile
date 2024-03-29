# frozen_string_literal: true

source 'http://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'codecov', require: false, group: :test
gem 'fast_jsonapi'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'api-pagination'
gem 'bcrypt', '~> 3.1.7'
gem 'composite_primary_keys', '=11.0'
gem 'will_paginate', '~> 3.1.0'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'
gem 'rubocop', require: false
# Active model serializer gem
gem 'knock'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'loofah', '>= 2.2.3'

# gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'time_difference'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
