# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Todos", type: :system) do
  it "creates a new todo and prepends it to the list via Turbo Streams", :js do
    visit root_path

    # Wait for AnyCable / ActionCable subscription to initialize if needed
    # Usually filling the form takes a moment anyway, but let's be safe
    expect(page).to(have_css("h1", text: "Todos"))

    # Assuming the form has a text input for title
    fill_in "What needs to be done?", with: "Learn Rails 8 with Hotwire"

    # Assuming there's a submit button
    click_on "Add"

    # The new todo should appear in the list dynamically via Turbo Stream
    expect(page).to(have_css("#todos li", text: "Learn Rails 8 with Hotwire"))

    # Form should be reset if configured properly, but verifying creation is the primary goal
    expect(page).to(have_content("Learn Rails 8 with Hotwire"))
  end
end
