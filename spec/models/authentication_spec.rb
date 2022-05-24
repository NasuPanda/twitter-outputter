require 'rails_helper'

RSpec.describe Authentication, type: :model do
  let(:authentication) { FactoryBot.create(:authentication) }
  let(:authentication_attributes) { FactoryBot.attributes_for(:authentication) }
  let(:user) { FactoryBot.create(:user) }

  describe 'attribute: uid' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        authentication.uid = 'example_uid'
        expect(authentication).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        authentication.uid = nil
        expect(authentication).to be_invalid
      end
    end
  end

  describe 'attribute: access_token' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        authentication.access_token = 'example_access_token'
        expect(authentication).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        authentication.access_token = nil
        expect(authentication).to be_invalid
      end
    end
  end

  describe 'attribute: access_token_secret' do
    context '存在するとき' do
      it 'バリデーションに成功すること' do
        authentication.access_token_secret = 'example_access_token_secret'
        expect(authentication).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        authentication.access_token_secret = nil
        expect(authentication).to be_invalid
      end
    end
  end

  describe 'belongs_to: User' do
    let!(:user_with_authentication) { FactoryBot.create(:user, :with_authentication) }

    it 'Userが削除されればそれに伴って削除されること' do
      expect {
        user_with_authentication.destroy
      }.to change(Authentication, :count).by(-1)
    end
  end

  describe 'Authentication.uid_is' do
    let(:authentication) { FactoryBot.create(:authentication) }

    context 'uidを持つAuthenticationがレコードに存在するとき' do
      it 'uidを持つAuthenticationを返すこと' do
        # 返り値はRelationなので要素を取り出す
        returned_authentication = Authentication.uid_is(authentication.uid).first
        expect(returned_authentication).to eq authentication
      end
    end

    context 'uidを持つAuthenticationがレコードに存在しないとき' do
      it '何も返さないこと' do
        expect(Authentication.uid_is('invalid_uid')).to be_blank
      end
    end
  end

  describe '#encrypt_access_token' do
    it 'access_token, access_token_secretが暗号化されること' do
      user.build_authentication(
        uid: authentication_attributes[:uid],
        access_token: authentication_attributes[:access_token],
        access_token_secret: authentication_attributes[:access_token_secret]
      )
      expect {
        user.save!
      }.to change{user.authentication.access_token}.and change{user.authentication.access_token_secret}
    end
  end

  describe '#decrypted_access_token' do
    it 'access_tokenが復号されて取り出されること' do
      token_before_encrypt = authentication_attributes[:access_token]

      user.create_authentication(
        uid: authentication_attributes[:uid],
        access_token: authentication_attributes[:access_token],
        access_token_secret: authentication_attributes[:access_token_secret]
      )
      token_decrypted = user.authentication.decrypted_access_token

      expect(token_decrypted).to eq token_before_encrypt
    end
  end

  describe '#decrypted_access_token_secret' do
    it 'access_token_secretが復号されて取り出されること' do
      token_before_encrypt = authentication_attributes[:access_token_secret]

      user.create_authentication(
        uid: authentication_attributes[:uid],
        access_token: authentication_attributes[:access_token],
        access_token_secret: authentication_attributes[:access_token_secret]
      )
      token_decrypted = user.authentication.decrypted_access_token_secret

      expect(token_decrypted).to eq token_before_encrypt
    end
  end
end
