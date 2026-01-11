source "https://rubygems.org"

ruby "3.2.9"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'rubocop', '~> 1.30', require: false
gem 'rubocop-rails', '2.19.1'

# HTTP client for weather API
gem "httparty"

gem 'cssbundling-rails'
gem 'rails-controller-testing'

group :development, :test do
  # see https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem 'byebug'
end

group :development do
  # use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # add speed badges [https://github.com/miniprofiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'pry-byebug'                  , '~> 3.10'
  gem 'pry-rails'                   , '0.3.9'
end

group :test do
  # use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails", "~> 7.0"
  gem "simplecov", require: false
end
