require 'rails_helper'

RSpec.describe "Pages::Settings", type: :request do
  describe "GET /setting" do
    let(:user) { FactoryBot.create(:user, :with_authentication, :with_notification_setting) }

    context 'ログインしているとき' do
          before { sign_in_as(user) }

      it "正常なレスポンスを返すこと" do
        get setting_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ログインしていないとき' do
      it 'rootにリダイレクトされること' do
        get setting_path
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "GET setting/edit" do
    let(:user) { FactoryBot.create(:user, :with_authentication, :with_notification_setting) }

    context 'ログインしているとき' do
          before { sign_in_as(user) }

      it "正常なレスポンスを返すこと" do
        get edit_setting_path, xhr: true
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ログインしていないとき' do
      it 'rootにリダイレクトされること' do
        get edit_setting_path, xhr: true
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "PUT /setting" do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let!(:setting) { FactoryBot.create(:notification_setting, user: user) }
    let!(:valid_params) { FactoryBot.attributes_for(:notification_setting) }

    context 'ログインしているとき' do
          before { sign_in_as(user) }

      context '有効なパラメータの場合' do
        it "正常なレスポンスを返すこと" do
          put setting_path, xhr: true, params: { notification_setting: valid_params }
          expect(response).to have_http_status(:ok)
        end

        it '更新されること' do
          before_update = setting.interval_to_check
          expect {
            put setting_path, xhr: true, params: { notification_setting: valid_params }
          }.to change{
            setting.reload.interval_to_check
          }.from(before_update).to(valid_params[:interval_to_check])
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) { FactoryBot.attributes_for(:notification_setting, interval_to_check: 0) }

        it '更新されないこと' do
          expect {
            put setting_path, xhr: true, params: { notification_setting: invalid_params }
          }.to_not change { setting.reload }
        end
      end
    end

    context 'ログインしていないとき' do
      it 'rootにリダイレクトすること' do
        put setting_path, xhr: true, params: { notification_setting: valid_params }
        expect(response).to redirect_to root_url
      end

      it '更新されないこと' do
        expect {
          put setting_path, xhr: true, params: { notification_setting: valid_params }
        }.to_not change { setting.reload }
      end
    end
  end

end
