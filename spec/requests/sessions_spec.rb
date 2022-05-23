require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { FactoryBot.create(:user, :with_authentication) }

  describe 'GET /auth/:provider/callback' do
    context '既存のユーザのとき' do
      it 'ログインすること' do
        sign_in_as(user)
        expect(is_logged_in?).to be_truthy
      end

      it 'cookiesにexternal_user_idが登録されること' do
        expect(cookies[:external_user_id]).to be_blank
        sign_in_as(user)
        expect(cookies[:external_user_id]).to_not be_blank
      end
    end

    context '新規ユーザのとき' do
      it '新規ユーザが作成されること' do
        expect { sign_up }.to change(User, :count).by(1)
      end

      it 'ログインすること' do
        sign_up
        expect(is_logged_in?).to be_truthy
      end

      it 'cookiesにexternal_user_idが登録されること' do
        expect(cookies[:external_user_id]).to be_blank
        sign_up
        expect(cookies[:external_user_id]).to_not be_blank
      end
    end
  end

  # ユーザが認証をキャンセルした時
  describe 'GET /auth/failure' do
    it 'rootにリダイレクトされること' do
      sign_in_with_denied_authentication
      expect(response).to redirect_to root_url
    end

    it '新規ユーザが作成されないこと' do
      expect { sign_up_with_denied_authentication }.to_not change(User, :count)
    end

    it 'ログインしないこと' do
      sign_in_with_denied_authentication
      expect(is_logged_in?).to_not be_truthy
    end
  end

  describe 'DELETE /logout' do
    before do
      sign_in_as(user)
    end

    it 'ログアウト出来ること' do
      delete logout_path
      expect(is_logged_in?).to_not be_truthy
    end
  end
end
