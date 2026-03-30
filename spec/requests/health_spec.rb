# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Health endpoint", type: :request) do
  describe "GET /up" do
    it "returns a successful response when database is healthy" do
      get "/up"
      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include("background-color: green"))
    end
  end
end
