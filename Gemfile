# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", github: "rails/rails", branch: "main"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"
# gem "mission_control-jobs"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Translations for Rails standard helpers
gem "rails-i18n"

gem "sidekiq"
gem "sidekiq-cron"
gem "anycable-rails"
gem "redis"

# Use S3 for Active Storage
gem "aws-sdk-s3"

gem "haml-rails"
gem "cancancan"
gem "rack-attack"
gem "maintenance_tasks"
gem "ssrf_filter"

group :development, :test do
  gem "parallel_tests"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Shopify Ruby styling [https://github.com/Shopify/ruby-style-guide]
  gem "rubocop-shopify", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "rubocop-haml", require: false
  gem "i18n-tasks", require: false
  gem "haml_lint", require: false

  gem "flog", require: false
  gem "flay", require: false
  gem "reek", require: false
  gem "skunk", require: false
end

group :development do
  gem "web-console"
  gem "foreman"
end

group :test do
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-parameterized"
  gem "rspec-retry"
  gem "capybara"
  gem "selenium-webdriver"
end

gem "hotwire-livereload", "~> 2.1", group: :development
