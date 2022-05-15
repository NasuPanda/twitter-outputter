require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { FactoryBot.create(:user) }
    context "有効なユーザのとき" do
      it "バリデーションに成功すること" do
        expect(user).to be_valid
      end
    end
    context "無効なユーザのとき" do
      it "providerが無効な値であればバリデーションに失敗すること" do
        user.provider = "invalid"
        expect(user).to_not be_valid
      end
      it "uidが空であればバリデーションに失敗すること" do
        user.uid = ""
        expect(user).to_not be_valid
      end
    end
  end
end
