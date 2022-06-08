require 'rails_helper'

RSpec.describe "Tags::Tagged", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/tags/tagged/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/tags/tagged/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
