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

  # 特定のstatusのPostを取得する
  def drafts
    return posts.find_all{ |post| post.draft? }
  end

  def published_posts
    return posts.find_all{ |post| post.published? }
  end

  def reserved_posts
    return posts.find_all{ |post| post.reserved? }
  end

  def post_tweet(text)
    client = twitter_client
    client.update(text)
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
    def self.find_by_auth_hash(auth_hash)
      uid = auth_hash[:uid]
      user = self.find_authentication_uid(uid).first
    end

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

    # TODO Twitter関連の処理をモジュールとして切り出す。サービスオブジェクト/concernのどちらが最適かはまた考える。
    # モックでテストしやすいようにメソッドに分離する
    def twitter_client
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:client_id]
        config.consumer_secret     = Rails.application.credentials.twitter[:client_secret]
        config.access_token        = self.authentication.decrypted_access_token
        config.access_token_secret = self.authentication.decrypted_access_token_secret
      end
    end
end
