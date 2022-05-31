require 'rails_helper'

RSpec.describe "Posts::Publisheds", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/posts/published/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/posts/published/create"
      expect(response).to have_http_status(:success)
    end
  end

end
