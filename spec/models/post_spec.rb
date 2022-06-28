require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'attribute: content' do
    let(:post) { FactoryBot.build(:post) }
    let(:user_with_post) { FactoryBot.create(:user, :with_post) }

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

  describe 'has_many_attacehd: images' do
    let(:post) { FactoryBot.create(:post) }

    context '5MBの画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/5MB.png"),
          filename: 'test_5MB.png',
          content_type: 'image/png'
        )
        expect(post).to be_valid
      end
    end

    context '10MBの画像が添付されたとき' do
      it 'バリデーションに失敗すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/10MB.png"),
          filename: 'test_10MB.png',
          content_type: 'image/png'
        )
        expect(post).to be_invalid
      end
    end

    context 'jpeg形式の画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/150x150.jpeg"),
          filename: 'test_150x150.jpeg',
          content_type: 'image/jpeg'
        )
        expect(post).to be_valid
      end
    end

    context 'png, jpeg, gif, webp以外のcontent-typeのファイルが添付されたとき' do
      it 'バリデーションに失敗すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/dummy.txt"),
          filename: 'test.txt',
          content_type: 'text/plain'
        )
      end
    end

    context '1枚の画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/1MB.png"),
          filename: 'test_5MB.png',
          content_type: 'image/png'
        )
        expect(post).to be_valid
      end
    end

    context '4枚の画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        images = %w(400x400 600x400 1200x900 1900x1900)
        images.each do |img_name|
          post.images.attach(
            io: File.open("#{Rails.root}/spec/fixtures/#{img_name}.png"),
            filename: "test_#{img_name}.png",
            content_type: 'image/png'
          )
        end
        expect(post).to be_valid
      end
    end

    context '5枚の画像が添付されたとき' do
      it 'バリデーションに失敗すること' do
        images = %w(400x400 600x400 800x600 1200x900 1900x1900)
        images.each do |img_name|
          post.images.attach(
            io: File.open("#{Rails.root}/spec/fixtures/#{img_name}.png"),
            filename: "test_#{img_name}.png",
            content_type: 'image/png'
          )
        end
        expect(post).to be_invalid
      end
    end

    context '横2100, 縦2100の画像が添付されたとき' do
      it 'バリデーションに失敗すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/2100x2100.png"),
          filename: 'test_2100x2100.png',
          content_type: 'image/png'
        )
        expect(post).to be_invalid
      end
    end

    context '横900, 縦1200の画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/1200x900.png"),
          filename: 'test_1200x900.png',
          content_type: 'image/png'
        )
        expect(post).to be_valid
      end
    end

    context '横1900, 縦1900の画像が添付されたとき' do
      it 'バリデーションに成功すること' do
        post.images.attach(
          io: File.open("#{Rails.root}/spec/fixtures/1900x1900.png"),
          filename: '1900x1900.png',
          content_type: 'image/png'
        )
        expect(post).to be_valid
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

    before { travel_to(Time.current) }

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
    let(:user) { FactoryBot.create(:user) }
    let(:draft) { FactoryBot.create(:post, :draft, user: user) }
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

  describe '#update_scheduled_tweet' do
    before do
      # Postオブジェクトがperform_later_scheduled_post_jobを受け取った時に .provider_job_idを持つオブジェクトを返すようにする
      # ScheduledPostJobオブジェクトがdelete_jobを受け取った時に実際にジョブを削除する処理が走らないようにする
      job_mock = double('PostJob')
      allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
      allow_any_instance_of(Post).to receive(:perform_later_scheduled_post_job).and_return(job_mock)
      allow_any_instance_of(ScheduledPostJob).to receive(:delete_job).and_return(true)
    end

    context 'ScheduledPostJobを持つ時' do
      let(:post) { FactoryBot.create(:post, :with_job) }

      it 'ScheduledPostJobが更新されること' do
        expect {
          post.update_scheduled_tweet
        }.to change{ post.reload.scheduled_post_job.job_id }
      end
    end

    context 'ScheduledPostJobを持たない時' do
      let(:post) { FactoryBot.create(:post) }

      it '実行後ScheduledPostJobを持たないこと' do
        post.update_scheduled_tweet
        expect(post.reload.scheduled_post_job).to be_blank
      end
    end
  end

  describe '#cancel_scheduled_tweet' do
    let(:post) { FactoryBot.create(:post, :with_job) }

    context 'ScheduledPostJobを持つ時' do
      it 'ScheduledPostJobが削除されること' do
        post.cancel_scheduled_tweet
        expect(post.reload.scheduled_post_job).to be_blank
      end
    end
  end

  describe '#scheduled_tweet_failure?' do
    let(:post) { FactoryBot.create(:post, :with_failure_job) }

    context 'statusがfailureのScheduledPostJobを持つ時' do
      it 'Trueを返すこと' do
        expect(post.scheduled_tweet_failure?).to be_truthy
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
