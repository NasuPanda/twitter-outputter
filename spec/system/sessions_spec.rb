require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let(:user) { FactoryBot.create(:user) }
  before do
    driven_by(:rack_test)
  end

  describe "ログインのテスト" do
    it "ログイン/ログアウト出来ること" do
      sign_in_as(user)
      expect(page).to have_content "ログインしました"
      expect(page).to have_content "ログアウト"

      click_on "ログアウト"
      expect(page).to have_content "ログアウトしました"
      expect(page).to have_content "Twitterでログイン"
    end
  end
end
