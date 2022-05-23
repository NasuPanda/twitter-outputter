require 'rails_helper'

RSpec.describe Authentication, type: :model do
  describe 'バリデーションのテスト' do
    let(:authentication) { FactoryBot.create(:authentication) }

    context '有効な属性のとき' do
      it 'バリデーションに成功すること' do
        expect(authentication).to be_valid
      end
    end

    context '無効な属性のとき' do
      it 'uidが存在しなければバリデーションに失敗すること' do
        authentication.uid = nil
        expect(authentication).to_not be_valid
      end
    end
  end

  describe 'scopeのテスト' do
    describe 'Authentication.uid_is' do
      let(:authentication) { FactoryBot.create(:authentication) }

      it 'uidを持つAuthenticationがレコードに存在するとき' do
        # 返り値はRelationなので要素を取り出す
        returned_authentication = Authentication.uid_is(authentication.uid).first
        expect(returned_authentication).to eq authentication
      end

      it 'uidを持つAuthenticationがレコードに存在しないとき' do
        expect(Authentication.uid_is('invalid_uid')).to be_blank
      end
    end
  end

  describe 'メソッドのテスト' do
    describe 'before_save' do
      describe '#encrypt_access_token' do
        # before_saveの挙動をテストしたいのでbuild→saveする
        let(:authentication) { FactoryBot.build(:authentication) }

        it 'access_token, access_token_secretが暗号化されること' do
          expect {
            authentication.save!
          }.to change{authentication.access_token}.and change{authentication.access_token_secret}
        end
      end
    end

    describe '#decrypted_access_token' do
      let(:authentication) { FactoryBot.build(:authentication) }

      it 'access_tokenが復号されて取り出されること' do
        token_before_encrypt = authentication.access_token
        authentication.encrypt_access_token
        token_decrypted = authentication.decrypted_access_token

        expect(token_decrypted).to eq token_before_encrypt
      end
    end

    describe '#decrypted_access_token_secret' do
      let(:authentication) { FactoryBot.build(:authentication) }

      it 'access_token_secretが復号されて取り出されること' do
        secret_before_encrypt = authentication.access_token_secret
        authentication.encrypt_access_token
        secret_decrypted = authentication.decrypted_access_token_secret

        expect(secret_decrypted).to eq secret_before_encrypt
      end
    end
  end
end
