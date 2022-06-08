require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'attribute: name' do
    let(:tag) { FactoryBot.build(:tag) }
    let(:user_with_tag) { FactoryBot.create(:user, :with_tag) }

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
        tag.name = ' '
        expect(tag).to be_invalid
      end
    end

    context 'ハッシュタグを除いて100字のとき' do
      it 'バリデーションに成功すること' do
        tag.name = "##{'a' * 100}"
        expect(tag).to be_valid
      end
    end

    context 'ハッシュタグを除いて101字のとき' do
      it 'バリデーションに失敗すること' do
        tag.name = "##{'a' * 101}"
        expect(tag).to be_invalid
      end
    end

    # テストケースの参考 : https://github.com/twitter/twitter-text/blob/master/conformance/validate.yml
    context '全て数字のとき' do
      it 'バリデーションに失敗すること' do
        tag.name = '#123'
        expect(tag).to be_invalid
      end
    end

    context '空白を含むとき' do
      it 'バリデーションに失敗すること' do
        tag.name = '#無効な ハッシュタグ'
      end
    end

    context '同一ユーザ内で重複があるとき' do
      it 'バリデーションに失敗すること' do
        existing_tag = user_with_tag.tags.first
        dup_name = existing_tag.name
        name_dup_tag = user_with_tag.tags.create(name: dup_name)
        expect(name_dup_tag).to be_invalid
      end
    end
  end

  describe 'attribute: is_tagged' do
    let(:tag) { FactoryBot.build(:tag) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(tag).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        tag.is_tagged = nil
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
