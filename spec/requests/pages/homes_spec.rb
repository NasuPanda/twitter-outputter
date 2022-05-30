require 'rails_helper'

RSpec.describe "Pages::Homes", type: :request do
  describe "GET /" do
    it "正常なレスポンスを返すこと" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
