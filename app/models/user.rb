class User < ApplicationRecord
  scope :find_authentication_uid, -> (uid) {
    joins(:authentication).merge(Authentication.uid_is(uid))
  }
  has_one :authentication, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :tags, dependent: :destroy
  accepts_nested_attributes_for :authentication

  def get_or_create_external_user_id
    return self.external_user_id if self.external_user_id
    external_user_id = SecureRandom.uuid
    self.update_attribute(:external_user_id, external_user_id)
    return external_user_id
  end

  # status: draft のPostを取得
  def drafts
    find_posts_by_status(:draft)
  end

  # status: draft のPostを更新日時降順で取得
  def drafts_by_recently_updated
    drafts.by_recently_updated
  end

  # status: published のPostを取得
  def published_posts
    find_posts_by_status(:published)
  end

  # status: published のPostを投稿日時降順で取得
  def published_posts_by_recently_posted
    published_posts.by_recently_posted
  end

  # status: scheduled のPostを取得
  def scheduled_posts
    find_posts_by_status(:scheduled)
  end

  # status: scheduled のPostを投稿予定日順で取得
  def scheduled_posts_by_recently_posting
    scheduled_posts.by_recently_posted
  end

  # is_taggedがtrueのtagを取得する
  def tagged_tags
    tags.where(is_tagged: true)
  end

  def post_tweet(text)
    client = twitter_client
    client.update!(text)
    # TODO 失敗した場合はキャッチする
    # returns
    # Twitter::Tweet (成功した場合)
    # raises
    # Twitter::Error::Unauthorized, Twitter::Error::DuplicateStatus
  end

  def self.find_or_create_by_auth_hash(auth_hash)
    user = self.find_by_auth_hash(auth_hash)
    if user
      # 認証解除→再登録時にトークンが無効になるため、ログインし直すたびに更新する
      user.authentication.update!(
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret
      )
    else
      user = self.create_by_auth_hash(auth_hash)
    end
    return user
  end

  private

    # statusを元にPostを探す
    def find_posts_by_status(status)
      posts.where(status: status)
    end

    # Twitter-OmniAuthから受け取ったハッシュを元にユーザを探す
    def self.find_by_auth_hash(auth_hash)
      uid = auth_hash[:uid]
      user = self.find_authentication_uid(uid).first
    end

    # Twitter-OmniAuthから受け取ったハッシュを元にユーザを作る
    def self.create_by_auth_hash(auth_hash)
      uid = auth_hash[:uid]
      user = self.new()
      user.build_authentication(
        uid: uid,
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret
      )
      user.save
      return user
    end

    # TwitterAPIを叩くためのクライアント
    # Userに依存しているのでUserに定義している
    def twitter_client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:client_id]
        config.consumer_secret     = Rails.application.credentials.twitter[:client_secret]
        config.access_token        = self.authentication.decrypted_access_token
        config.access_token_secret = self.authentication.decrypted_access_token_secret
      end
    end
end
