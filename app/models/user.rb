class User < ApplicationRecord
  validates :uid, presence: true, uniqueness: true
  validate :provider_should_be_twitter
  # TODO access_token, secret をモデル化したものをhas_oneする

  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]

    User.find_or_create_by!(provider: provider, uid: uid)
  end

  private
    def provider_should_be_twitter
      if provider != 'twitter'
        errors.add(:provider, "Twitter以外の値は無効です")
      end
    end
end
