require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { FactoryBot.build(:post) }
  let(:draft) { FactoryBot.build(:post, :draft) }
  let(:user_with_post) { FactoryBot.create(:user, :with_post) }

  describe 'attribute: is_posted' do
    context '真偽値のとき' do
      it 'バリデーションに成功すること' do
        expect(draft).to be_valid
        expect(post).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        post.is_posted = nil
        expect(post).to be_invalid
      end
    end
  end

  describe 'attribute: content' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(post).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        post.content = nil
        expect(post).to be_invalid
      end
    end

    context '空白のとき' do
      it 'バリデーションに失敗すること' do
        post.content = '  '
        expect(post).to be_invalid
      end
    end

    context '140字のとき' do
      it 'バリデーションに成功すること' do
        post.content = 'a' * 140
        expect(post).to be_valid
      end
    end

    context '141字のとき' do
      it 'バリデーションに失敗すること' do
        post.content = 'a' * 141
        expect(post).to be_invalid
      end
    end

    context '同一ユーザ内で重複があるとき' do
      it 'バリデーションに失敗すること' do
        existing_post = user_with_post.posts.first
        dup_content = existing_post.content
        user_with_post.posts.create(content: dup_content)
        expect(user_with_post).to be_invalid
      end
    end
  end

  describe 'attribute: post_at' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(post).to be_valid
      end
    end

    context '下書きかつ存在しないとき' do
      it 'バリデーションに成功すること' do
        draft.post_at = nil
        expect(draft).to be_valid
      end
    end

    context '投稿済みかつ存在しないとき' do
      it 'バリデーションに失敗すること' do
        post.post_at = nil
        expect(post).to be_invalid
      end
    end
  end

  describe 'belongs_to: User' do
    let!(:user_with_post) { FactoryBot.create(:user, :with_post) }

    it 'Userが削除されればそれに伴って削除されること' do
      expect {
        user_with_post.destroy
      }.to change(Post, :count).by(-1)
    end
  end
end
