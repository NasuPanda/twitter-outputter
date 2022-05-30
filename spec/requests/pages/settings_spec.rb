require 'rails_helper'

RSpec.describe "Pages::Settings", type: :request do
  describe "GET /setting" do
    it "正常なレスポンスを返すこと" do
      get setting_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET setting/edit" do
    it "正常なレスポンスを返すこと" do
      get edit_setting_path
      expect(response).to have_http_status(:ok)
    end
  end

  # TODO : コントローラの中身を実装したら
  describe "PUT /setting", :skip do
    it "正常なレスポンスを返すこと" do
      put setting_path, params: {}
      expect(response).to have_http_status(:ok)
    end
  end

end
