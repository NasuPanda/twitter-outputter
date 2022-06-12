require 'rails_helper'

RSpec.describe "Pages::Settings", type: :request do
  let(:user) { FactoryBot.create(:user, :with_authentication) }

  describe "GET /setting" do
    context 'ログインしているとき' do
      before do
        sign_in_as(user)
      end

      it "正常なレスポンスを返すこと" do
        get setting_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET setting/edit" do
    context 'ログインしているとき' do
      before do
        sign_in_as(user)
      end

      it "正常なレスポンスを返すこと" do
        get edit_setting_path
        expect(response).to have_http_status(:ok)
      end
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
