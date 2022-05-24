require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { FactoryBot.create(:tag) }

  describe 'attribute: name' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(tag).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        tag.name = nil
        expect(tag).to be_invalid
      end
    end

    context '空白のとき' do
      it 'バリデーションに失敗すること' do
        tag.name = '  '
        expect(tag).to be_invalid
      end
    end

    context '100字のとき' do
      it 'バリデーションに成功すること' do
        tag.name = 'a' * 100
        expect(tag).to be_valid
      end
    end

    context '101字のとき' do
      it 'バリデーションに失敗すること' do
        tag.name = 'a' * 101
        expect(tag).to be_invalid
      end
    end
  end

  describe 'belongs_to: User' do
    let!(:user_with_tag) { FactoryBot.create(:user, :with_tag) }

    it 'Userが削除されればそれに伴って削除されること' do
      # 普通のletだとuser_with_tagが呼ばれたタイミングで生成→destroyされるのでcountが変わらない。
      expect {
        user_with_tag.destroy
      }.to change(Tag, :count).by(-1)
    end
  end
end
