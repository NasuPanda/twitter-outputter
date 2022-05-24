require 'rails_helper'

RSpec.describe Post, type: :model do
  # validates :is_posted, presence: true, inclusion: [true, false]
  # validates :post_at, presence: true, allow_nil: true
  # validates :content, presence: true, length: { maximum: 140 }
  describe "バリデーションのテスト" do
    let(:post) { FactoryBot.create(:post) }
    let(:draft) { FactoryBot.create(:post, :draft) }

    context "有効な属性のとき" do
      it 'バリデーションに成功すること' do
        expect(post).to be_valid
      end

      it '下書きかつpost_atが存在しないときバリデーションに成功すること' do
        draft.post_at = nil
        expect(draft).to be_valid
      end

      it 'contentが140字のときバリデーションに成功すること' do
        post.content = 'a' * 139
        expect(post).to be_valid
      end
    end

    context "無効な属性のとき" do
      it 'is_postedが真偽値以外の値ならバリデーションに失敗すること' do
        post.is_posted = nil
        expect(post).to_not be_valid
      end

      it '投稿済かつpost_atが存在しないときバリデーションに失敗すること' do
        # nilは許容するので空白でテスト
        post.post_at = ''
        expect(post).to_not be_valid
      end

      it 'contentが存在しなければバリデーションに失敗すること' do
        post.content = ''
        expect(post).to_not be_valid
      end

      it 'contentが140字以上ならバリデーションに失敗すること' do
        post.content = 'a' * 141
        expect(post).to_not be_valid
      end
    end
  end

  describe "関連付けのテスト" do
    let!(:user_with_post) { FactoryBot.create(:user, :with_post) }

    it 'Userが削除されればそれに伴って削除されること' do
      expect {
        user_with_post.destroy
      }.to change(Post, :count).by(-1)
    end
  end
end
