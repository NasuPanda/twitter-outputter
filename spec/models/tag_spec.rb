require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーションのテスト' do
    let(:tag) { FactoryBot.create(:tag) }

    context '有効な属性のとき' do
      it 'バリデーションに成功すること' do
        expect(tag).to be_valid
      end
    end

    context "無効な属性のとき" do
      it 'nameが存在しなければバリデーションに失敗すること' do
        tag.name = ''
        expect(tag).to_not be_valid
      end
    end
  end

  describe "関連付けのテスト" do
    let!(:user_with_tag) { FactoryBot.create(:user, :with_tag) }

    it 'Userが削除されればそれに伴って削除されること' do
      # 普通のletだとuser_with_tagが呼ばれたタイミングで生成→destroyされるのでcountが変わらない。
      expect {
        user_with_tag.destroy
      }.to change(Tag, :count).by(-1)
    end
  end
end
