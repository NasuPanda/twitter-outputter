require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:draft) { FactoryBot.build(:post, :draft) }
  let(:reserved) { FactoryBot.build(:post, :reserved) }
  let(:user_with_post) { FactoryBot.create(:user, :with_post) }

  describe 'attribute: content' do
    let(:post) { FactoryBot.build(:post) }

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
    let(:post) { FactoryBot.build(:post) }
    let(:draft) { FactoryBot.build(:post, :draft) }
    let(:reserved) { FactoryBot.build(:post, :reserved) }

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

    context '予約投稿かつ存在しないとき' do
      it 'バリデーションに失敗すること' do
        reserved.post_at = nil
        expect(reserved).to be_invalid
      end
    end

    context '投稿済みかつ存在しないとき' do
      it 'バリデーションに失敗すること' do
        post.post_at = nil
        expect(post).to be_invalid
      end
    end
  end

  describe 'attribute: status' do
    let(:user) { FactoryBot.create(:user) }

    it 'デフォルト値がdraftであること' do
      created_post = user.posts.create(content: 'test content')
      expect(created_post.draft?).to be_truthy
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
