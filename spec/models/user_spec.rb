require 'rails_helper'

RSpec.describe User, type: :model do
  shared_context '下書き,投稿,予約投稿を5つずつ持つユーザ' do
    let(:user) {
      FactoryBot.create(
        :user,
        :with_published_posts,
        :with_drafts,
        :with_scheduled_posts
      )
    }
  end

  describe 'attribute: external_user_id' do
    let(:user) { FactoryBot.build(:user) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        user.external_user_id = 'external_user_id'
        expect(user).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに成功すること' do
        user.external_user_id = nil
        expect(user).to be_valid
      end
    end
  end

  describe 'User.find_authentication_uid' do
    let(:authenticated_user) { FactoryBot.create(:user, :with_authentication) }

    context 'uidを持つUserがレコードに存在するとき' do
      it 'uidを持つユーザがレコードに存在すればそのユーザを返すこと' do
        uid = authenticated_user.authentication.uid
        # 返り値はActiveRecord::Relationなので要素を取り出す必要がある
        returned_user = User.find_authentication_uid(uid).first
        expect(returned_user).to eq authenticated_user
      end
    end

    context 'uidを持つUserがレコードに存在しないとき' do
        it 'uidを持つユーザがレコードに存在しなければnilを返すこと' do
          expect(User.find_authentication_uid('invalid_uid')).to be_blank
        end
      end
  end

  describe '#get_or_create_external_user_id' do
    let(:user) { FactoryBot.build(:user) }

    context 'インスタンスがexternal_user_idを持っているとき' do
      it 'インスタンスが持つexternal_user_idを返すこと' do
        expect(user.get_or_create_external_user_id).to eq user.external_user_id
      end
    end

    context 'インスタンスがexternal_user_idを持たないとき' do
      it 'external_user_idを作成してインスタンスのレコードを更新すること' do
        user.external_user_id = nil
        expect {
          user.get_or_create_external_user_id
        }.to change(user, :external_user_id)
      end
    end
  end

  describe '#drafts' do
    context '下書きが存在するとき' do
      include_context '下書き,投稿,予約投稿を5つずつ持つユーザ'

      it '下書きを全て取得すること' do
        expect(user.drafts.count).to eq(5)
      end

      it '下書きのみを取得すること' do
        user.drafts.each do |draft|
          expect(draft.draft?).to be_truthy
        end
      end
    end

    context '下書きが存在しないとき' do
      let(:user) { FactoryBot.create(:user, :with_published_posts, :with_scheduled_posts) }

      it '空のリストを返すこと' do
        expect(user.drafts).to be_blank
      end
    end
  end

  describe '#published_posts' do
    context '投稿済の投稿が存在するとき' do
      include_context '下書き,投稿,予約投稿を5つずつ持つユーザ'

      it '投稿済の投稿を全て取得すること' do
        expect(user.published_posts.count).to eq(5)
      end

      it '投稿済の投稿のみを取得すること' do
        user.published_posts.each do |published_post|
          expect(published_post.published?).to be_truthy
        end
      end
    end

    context '投稿済みの投稿が存在しないとき' do
      let(:user) { FactoryBot.create(:user, :with_drafts, :with_scheduled_posts) }

      it '空のリストを返すこと' do
        expect(user.published_posts).to be_blank
      end
    end
  end

  describe '#scheduled_posts' do
    context '予約投稿が存在するとき' do
      include_context '下書き,投稿,予約投稿を5つずつ持つユーザ'

      it '予約投稿を全て取得すること' do
        expect(user.scheduled_posts.count).to eq(5)
      end

      it '予約投稿のみを取得すること' do
        user.scheduled_posts.each do |scheduled_post|
          expect(scheduled_post.scheduled?).to be_truthy
        end
      end
    end

    context '予約投稿が存在しないとき' do
      let(:user) { FactoryBot.create(:user, :with_drafts, :with_published_posts) }

      it '空のリストを返すこと' do
        expect(user.scheduled_posts).to be_blank
      end
    end
  end

  describe '#tagged_tags' do
    context 'tagged_tagsが存在するとき' do
      # tagged_tagを5つ持つ
      let(:user) { FactoryBot.create(:user, :with_tagged_tags) }

      it 'tagged_tagsを全て取得すること' do
        expect(user.tagged_tags.count).to eq(5)
      end
    end

    context 'tagged_tagsが存在しないとき' do
      let(:user) { FactoryBot.build(:user) }

      it '空のリストを返すこと' do
        expect(user.tagged_tags).to be_blank
      end
    end
  end

  describe '#post_tweet' do
    let!(:authenticated_user) { FactoryBot.create(:user, :with_authentication) }
    before { twitter_mock_from_instance(authenticated_user) }

    context '画像を持たないPostのとき' do
      let(:post_without_image) { FactoryBot.create(:post, user: authenticated_user) }
      it '通常の投稿をすること' do
        authenticated_user.post_tweet(post_without_image)
        expect(authenticated_user).to have_received(:post_tweet_without_media)
      end
    end

    context '画像が添付されたPostのとき' do
      let(:post_with_image) { FactoryBot.create(:post, :with_image, user: authenticated_user) }
      it '画像付き投稿をすること' do
        authenticated_user.post_tweet(post_with_image)
        expect(authenticated_user).to have_received(:post_tweet_with_media)
      end
    end
  end

  describe '#most_recent_tweet' do
    let(:user) { FactoryBot.create(:user, :with_authentication) }

    context 'ツイートが存在する場合' do
      it 'ツイートを取得出来ること' do
        twitter_client_mock = double('TwitterClient')
        allow(user).to receive(:twitter_client).and_return(twitter_client_mock)
        allow(twitter_client_mock).to receive(:user_timeline).and_return(['tweet'])

        expect(user.most_recent_tweet).to be_present
      end
    end

    context 'ツイートが存在しない場合' do
      it 'ツイートを取得出来ないこと' do
        twitter_client_mock = double('TwitterClient')
        allow(user).to receive(:twitter_client).and_return(twitter_client_mock)
        allow(twitter_client_mock).to receive(:user_timeline).and_return([])

        expect(user.most_recent_tweet).to be_nil
      end
    end
  end

  describe 'User.find_or_create_by_auth_hash' do
    let(:authenticated_user) { FactoryBot.create(:user, :with_authentication) }
    before do
      authentication = authenticated_user.authentication
      @auth_hash = OmniAuth::AuthHash.new(
        uid: authentication.uid,
        credentials: OmniAuth::AuthHash.new(
          token: authentication.access_token,
          secret: authentication.access_token_secret
        )
      )
    end

    context 'uidを持つUserがレコードに存在するとき' do
      it 'uidを持つユーザを返すこと' do
        returned_user = User.find_or_create_by_auth_hash(@auth_hash)
        expect(returned_user).to eq authenticated_user
      end

      it 'access_token, access_token_secretが更新されること' do
        new_token = 'updated_token'
        new_secret = 'updated_token_secret'
        @auth_hash.credentials.token = new_token
        @auth_hash.credentials.secret = new_secret
        returned_user = User.find_or_create_by_auth_hash(@auth_hash)

        # 復号したaccess_tokenと比較したいのでdecrypted**メソッドを使う
        expect(returned_user.authentication.decrypted_access_token).to eq new_token
        expect(returned_user.authentication.decrypted_access_token_secret).to eq new_secret
      end
    end

    context 'uidを持つUserがレコードに存在しないとき' do
      it 'uidを持つユーザを新規作成すること' do
        @auth_hash[:uid] = 'invalid_uid'
        expect {
          returned_user = User.find_or_create_by_auth_hash(@auth_hash)
          expect(returned_user).to_not eq authenticated_user
        }.to change(User, :count).by(1)
      end
    end
  end

  # private method なので sendメソッドを使ってテストする
  describe '#download_all_attachments' do
    context '添付画像が1枚のとき' do
      let(:user) { FactoryBot.create(:user) }
      let(:post_with_an_image) { FactoryBot.create(:post, :with_image, user: user) }

      it '長さ1の配列が返ること' do
        user.send(:download_all_attachments, post_with_an_image.images) do |images|
          expect(images.size).to eq(1)
        end
      end

      it '各要素がTempfileオブジェクトのインスタンスであること' do
        user.send(:download_all_attachments, post_with_an_image.images) do |images|
          images.each { |image| expect(image).to be_a(Tempfile) }
        end
      end
    end

    context '添付画像が2枚のとき' do
      let(:user) { FactoryBot.create(:user) }
      let(:post_with_two_images) { FactoryBot.create(:post, user: user) }
      before {
        1.step(2) { |n| post_with_two_images.images.attach(fixture_file_upload("#{n}.png")) }
      }

      it '長さ2の配列が返ること' do
        user.send(:download_all_attachments, post_with_two_images.images) do |images|
          expect(images.size).to eq(2)
        end
      end

      it '各要素がTempfileオブジェクトのインスタンスであること' do
        user.send(:download_all_attachments, post_with_two_images.images) do |images|
          images.each { |image| expect(image).to be_a(Tempfile) }
        end
      end
    end

    context '添付画像が3枚のとき' do
      let(:user) { FactoryBot.create(:user) }
      let(:post_with_three_images) { FactoryBot.create(:post, user: user) }
      before {
        1.step(3) { |n| post_with_three_images.images.attach(fixture_file_upload("#{n}.png")) }
      }

      it '長さ3の配列が返ること' do
        user.send(:download_all_attachments, post_with_three_images.images) do |images|
          expect(images.size).to eq(3)
        end
      end

      it '各要素がTempfileオブジェクトのインスタンスであること' do
        user.send(:download_all_attachments, post_with_three_images.images) do |images|
          images.each { |image| expect(image).to be_a(Tempfile) }
        end
      end
    end

    context '添付画像が4枚のとき' do
      let(:user) { FactoryBot.create(:user) }
      let(:post_with_four_images) { FactoryBot.create(:post, user: user) }
      before {
        1.step(4) { |n| post_with_four_images.images.attach(fixture_file_upload("#{n}.png")) }
      }

      it '長さ4の配列が返ること' do
        user.send(:download_all_attachments, post_with_four_images.images) do |images|
          expect(images.size).to eq(4)
        end
      end

      it '各要素がTempfileオブジェクトのインスタンスであること' do
        user.send(:download_all_attachments, post_with_four_images.images) do |images|
          images.each { |image| expect(image).to be_a(Tempfile) }
        end
      end
    end
  end
end
