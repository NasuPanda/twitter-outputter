require 'rails_helper'

RSpec.describe "Tags::Addeds", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/tags/added/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/tags/added/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
