# typed: false
# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production? || Rails.env.beta?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!

Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }

# Minimize BCrypt cost to speed up token/password hashing in tests (saves ~150-300ms per token/password creation)
begin
  require "bcrypt"
  BCrypt::Engine.cost = BCrypt::Engine::MIN_COST
rescue LoadError
  # ignore
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort(e.to_s.strip)
end
RSpec.configure do |config|
  config.include(ActiveSupport::Testing::TimeHelpers)

  # PG statement_timeout runs inside the transactional fixture's transaction (before(:each) runs after BEGIN).
  # It catches SQL hangs cleanly — PG aborts the statement without corrupting the AR connection.
  config.before do |example|
    timeout_seconds = example.metadata[:timeout] || ENV.fetch("EXAMPLE_TIMEOUT", 60).to_i
    pg_timeout_ms = [(timeout_seconds - 2) * 1000, 1000].max
    ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '#{pg_timeout_ms}'")
  end

  # Timeout.timeout is a safety net for non-SQL hangs (e.g. infinite Ruby loops).
  # Since PG kills queries first, Thread.raise from Timeout rarely fires, keeping AR connections clean.
  config.around do |example|
    timeout_seconds = example.metadata[:timeout] || ENV.fetch("EXAMPLE_TIMEOUT", 60).to_i
    Timeout.timeout(timeout_seconds) do
      example.run
    end
  rescue Timeout::Error, Timeout::ExitException
    raise Timeout::Error, "Test timed out after #{timeout_seconds} seconds: #{example.full_description}"
  end

  # Ensure no bleeding data
  config.before(:suite) do
    if defined?(DatabaseCleaner)
      DatabaseCleaner.clean_with(:truncation)
    end
  end

  config.define_derived_metadata(file_path: %r{/spec/integration/}) do |metadata|
    metadata[:integration] = true
  end

  # System specs (Selenium/headless Chrome) are inherently slow — skip in bin/lint, run in bin/long-lint
  config.define_derived_metadata(file_path: %r{/spec/system/}) do |metadata|
    metadata[:slow] = true
  end

  config.filter_run_excluding(integration: true) unless ENV["INTEGRATION"]

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join("spec/fixtures"),
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-1/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.after(:suite) do
    if defined?(Capybara) && Capybara.current_session.respond_to?(:driver)
      driver = Capybara.current_session.driver
      driver.quit if driver.respond_to?(:quit)
    end
  end
end
