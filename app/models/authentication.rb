class Authentication < ApplicationRecord
  scope :uid_is, -> uid {
    where(uid: uid)
  }
  before_save :encrypt_access_token
  belongs_to :user

  validates :uid, presence: true

  def encrypt_access_token
    self.access_token = crypt.encrypt_and_sign(access_token)
    self.access_token_secret = crypt.encrypt_and_sign(access_token_secret)
  end

  def decrypted_access_token
    crypt.decrypt_and_verify(self.access_token)
  end

  def decrypted_access_token_secret
    crypt.decrypt_and_verify(self.access_token_secret)
  end

  private
    def crypt
      @crypt ||= set_crypt
    end

    def set_crypt
      key_len = ActiveSupport::MessageEncryptor.key_len
      secret = Rails.application.key_generator.generate_key('salt', key_len)
      ActiveSupport::MessageEncryptor.new(secret)
    end
end
