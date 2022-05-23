require 'rails_helper'

RSpec.describe 'Sessions', type: :system do
  let(:user) { FactoryBot.create(:user, :with_authentication) }
  before do
    driven_by(:rack_test)
  end

  describe 'ログインのテスト' do
    context '既存ユーザの場合' do
      it 'ログイン/ログアウト出来ること' do
        sign_in_as(user)
        expect(page).to have_content 'ログインしました'
        expect(page).to have_content 'ログアウト'

        click_on 'ログアウト'
        expect(page).to have_content 'ログアウトしました'
        expect(page).to have_content 'Twitterでログイン'
      end
    end

    context '新規ユーザの場合' do
      it 'サインアップ/ログアウト出来ること' do
        sign_up
        expect(page).to have_content 'ログインしました'
        expect(page).to have_content 'ログアウト'

        click_on 'ログアウト'
        expect(page).to have_content 'ログアウトしました'
        expect(page).to have_content 'Twitterでログイン'
      end
    end

    context '認証が拒否された場合' do
      it 'ログイン出来ないこと' do
        sign_in_with_denied_authentication
        expect(page).to have_content 'ログインをキャンセルしました'
        expect(page).to have_content 'Twitterでログイン'
      end
    end
  end
end
