class User < ApplicationRecord
  scope :find_authentication_uid, -> (uid) {
    joins(:authentication).merge(Authentication.uid_is(uid))
  }
  has_one :authentication, dependent: :destroy
  accepts_nested_attributes_for :authentication

  def find_or_create_external_user_id
    return self.external_user_id if self.external_user_id
    external_user_id = SecureRandom.uuid
    self.update_attribute(:external_user_id, external_user_id)
    return external_user_id
  end

  def post_tweet(text)
    client = twitter_client
    client.update(text)
  end

  def self.find_or_create_by_auth_hash(auth_hash)
    uid = auth_hash[:uid]
    # scopeの返り値はRelationなので取り出す必要がある
    unless user = self.find_authentication_uid(uid).first
      user = self.new()
      user.build_authentication(
        uid: uid,
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret
      )
      user.save
    end
    return user
  end

  private
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
