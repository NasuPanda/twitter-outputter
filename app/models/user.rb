require 'bcrypt'

class User < ApplicationRecord
  has_one :authentication, dependent: :destroy
  accepts_nested_attributes_for :authentication

  # ユーザの作成 or 取得
  def create_authentication_from_auth_hash!(auth_hash)
    self.build_authentication(
      uid: auth_hash[:uid],
      access_token: auth_hash.credentials.token,
      access_token_secret: auth_hash.credentials.secret
    )
    self.save!
  end

  def set_external_user_id(external_user_id)
    self.update_attribute(:external_user_id, external_user_id)
  end

  # TODO Tweeter関連の処理をモジュールとして切り出す
  # サービスオブジェクト/concernのどちらが最適化はまた考える。
  # サービスオブジェクトは状態を持たないもの。callメソッドだけを持つ。複雑なドメインを分離するために使う。複数のモデルから使われるような場合使う。
  def post_tweet(text)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.twitter[:client_id]
      config.consumer_secret     = Rails.application.credentials.twitter[:client_secret]
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
    client.update(text)
  end

  def access_token
    # self = user
    crypt.decrypt_and_verify(self.authentication.access_token)
  end

  def access_token_secret
    # self = user
    crypt.decrypt_and_verify(self.authentication.access_token_secret)
  end

  def crypt
    key_len = ActiveSupport::MessageEncryptor.key_len
    secret = Rails.application.key_generator.generate_key('salt', key_len)
    ActiveSupport::MessageEncryptor.new(secret)
  end
end
