# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Todos", type: :request) do
  let!(:todo) { Todo.create!(title: "Write business value tests") }

  describe "GET /todos" do
    it "renders a successful response" do
      get todos_path
      puts "STATUS: #{response.status}"
      puts "BODY: #{response.body}"
      expect(response).to(be_successful)
      expect(response.body).to(include("Write business value tests"))
    end
  end
end
