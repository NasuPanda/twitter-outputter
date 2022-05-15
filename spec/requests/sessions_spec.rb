require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET /auth/:provider/callback' do
    it "ログイン出来ること" do
      sign_in_as(user)
      expect(is_logged_in?).to be_truthy
    end
  end

  describe 'DELETE /logout' do
    before do
      sign_in_as(user)
    end
    it "ログアウト出来ること" do
      delete logout_path
      expect(is_logged_in?).to_not be_truthy
    end
  end
end
