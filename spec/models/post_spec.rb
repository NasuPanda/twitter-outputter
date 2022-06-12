require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:draft) { FactoryBot.build(:post, :draft) }
  let(:scheduled) { FactoryBot.build(:post, :scheduled) }
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

    # NOTE: twitterの投稿は280バイトまで
    context '1バイト文字が280字のとき' do
      it 'バリデーションに成功すること' do
        post.content = 'a' * 280
        expect(post).to be_valid
      end
    end

    context '2バイト文字が140字のとき' do
      it 'バリデーションに成功すること' do
        post.content = 'あ' * 140
        expect(post).to be_valid
      end
    end

    context '1バイト文字が281字のとき' do
      it 'バリデーションに失敗すること' do
        post.content = 'a' * 281
        expect(post).to be_invalid
      end
    end

    context '2バイト文字が141字のとき' do
      it 'バリデーションに失敗すること' do
        post.content = 'あ' * 141
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
    let(:draft) { FactoryBot.build(:post, :draft) }
    let(:scheduled) { FactoryBot.build(:post, :scheduled) }
    let(:published_post) { FactoryBot.build(:post, :published) }

    context '下書きの場合' do
      context '存在するとき' do
        it 'バリデーションに成功すること' do
          expect(draft).to be_valid
        end
      end

      context '存在しないとき' do
        it 'バリデーションに成功すること' do
          draft.post_at = nil
          expect(draft).to be_valid
        end
      end
    end

    context '予約投稿の場合' do
      context '存在しないとき' do
        it 'バリデーションに失敗すること' do
          scheduled.post_at = nil
          expect(scheduled).to be_invalid
        end
      end

      context '現在時刻より遅いとき' do
        it 'バリデーションに失敗すること' do
          scheduled.post_at = 1.days.ago
          expect(scheduled).to be_invalid
        end
      end

      context '現在時刻の1分前のとき' do
        it 'バリデーションに失敗すること' do
          scheduled.post_at = 1.minutes.ago
          expect(scheduled).to be_invalid
        end
      end

      context '現在時刻の1年後のとき' do
        it 'バリデーションに成功すること' do
          scheduled.post_at = 1.years.from_now
          expect(scheduled).to be_valid
        end
      end

      context '現在時刻の1年+1分後のとき' do
        it 'バリデーションに失敗すること' do
          scheduled.post_at = 1.years.from_now + 1.minutes
          expect(scheduled).to be_invalid
        end
      end
    end

    context '投稿済の場合' do
      context '存在するとき' do
        it 'バリデーションに成功すること' do
          expect(published_post).to be_valid
        end
      end

      context '存在しないとき' do
        it 'バリデーションに失敗すること' do
          published_post.post_at = nil
          expect(published_post).to be_invalid
        end
      end
    end
  end

  describe 'attribute: status' do
    let(:user) { FactoryBot.create(:user) }

    it 'デフォルト値がdraftであること' do
      post = user.posts.build(content: 'test content')
      expect(post.draft?).to be_truthy
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

  describe '#to_draft' do
    let(:scheduled_post) { FactoryBot.build(:post, :scheduled) }
    let(:published_post) { FactoryBot.build(:post, :published) }

    context '予約投稿のとき' do
      it '下書きに変更されること' do
        expect { scheduled_post.to_draft }.to change{ scheduled_post.status }
          .from('scheduled').to('draft')
      end
    end

    context '投稿済のとき' do
      it 'PublishedToDraftError が発生すること' do
        expect{ published_post.to_draft }.to raise_error(Post::PublishedToDraftError)
      end
    end
  end

  describe '#to_published' do
    let(:draft) { FactoryBot.build(:post, :draft) }
    let(:scheduled_post) { FactoryBot.build(:post, :scheduled) }

    before do
      travel_to(Time.current)
    end

    context '下書きのとき' do
      it '投稿済に変更されること' do
        expect { draft.to_published }.to change{ draft.status }
          .from('draft').to('published')
      end

      it 'post_atが現在時刻に変更されること' do
        draft.to_published
        expect(draft.post_at).to eq(Time.current)
      end
    end

    context '予約投稿のとき' do
      it '投稿済に変更されること' do
        expect { scheduled_post.to_published }.to change{ scheduled_post.status }
          .from('scheduled').to('published')
      end

      it 'post_atが現在時刻に変更されること' do
        scheduled_post.to_published
        expect(scheduled_post.post_at).to eq(Time.current)
      end
    end
  end

  describe '#to_scheduled' do
    let(:draft) { FactoryBot.build(:post, :draft) }
    let(:published_post) { FactoryBot.build(:post, :published) }

    context '下書きのとき' do
      it '予約投稿に変更されること' do
        expect { draft.to_scheduled }.to change{ draft.status }
          .from('draft').to('scheduled')
      end
    end

    context '投稿済のとき' do
      it 'PublishedToScheduledError が発生すること' do
        expect{ published_post.to_scheduled }.to raise_error(Post::PublishedToScheduledError)
      end
    end
  end

  describe '#add_tags_to_content' do
    let(:post) { FactoryBot.build(:post) }
    let(:tags) { FactoryBot.create_list(:tag, 3) }

    context 'タグのリストが渡されたとき' do
      it 'post.contentに半角スペース区切りでtag.nameが追加されること' do
        expected_content = post.content.dup
        tags.each do |tag|
          expected_content += ' '
          expected_content += tag.name
        end

        post.add_tags_to_content(tags)
        expect(post.content).to eq(expected_content)
      end
    end

    context '空のリストが渡されたとき' do
      it 'post.contentが変化しないこと' do
        expect{ post.add_tags_to_content([]) }.to_not change{ post.content }
      end
    end

    context 'タグ以外のリストが渡されたとき' do
      it 'NoMethodError が発生すること' do
        expect{ post.add_tags_to_content(['tag', 'tag2']) }.to raise_error(NoMethodError)
      end
    end
  end
end
