# frozen_string_literal: true

require "capybara/rspec"
require "selenium-webdriver"

Capybara.register_driver(:headless_chromium) do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  # Point to the Chromium binary installed in Dockerfile.dev if it exists (for docker runs)
  # Otherwise, let selenium-manager find Chrome natively on the host machine (e.g., macOS)
  if File.exist?("/usr/bin/chromium")
    options.binary = "/usr/bin/chromium"
  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
  )
end

Capybara.javascript_driver = :headless_chromium

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :headless_chromium
  end
end
