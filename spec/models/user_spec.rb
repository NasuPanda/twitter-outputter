require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:authenticated_user) { FactoryBot.create(:user, :with_authentication) }

  describe 'attribute: external_user_id' do

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
    context "uidを持つUserがレコードに存在するとき" do
      it 'uidを持つユーザがレコードに存在すればそのユーザを返すこと' do
        uid = authenticated_user.authentication.uid
        # 返り値はActiveRecord::Relationなので要素を取り出す必要がある
        returned_user = User.find_authentication_uid(uid).first
        expect(returned_user).to eq authenticated_user
      end
    end

    context "uidを持つUserがレコードに存在しないとき" do
        it 'uidを持つユーザがレコードに存在しなければnilを返すこと' do
          expect(User.find_authentication_uid('invalid_uid')).to be_blank
        end
      end
  end

  describe '#get_or_create_external_user_id' do
    context 'インスタンスがexternal_user_idを持っているとき' do
      it 'インスタンスが持つexternal_user_idを返すこと' do
        expect(user.get_or_create_external_user_id).to eq user.external_user_id
      end
    end

    context "インスタンスがexternal_user_idを持たないとき" do
      it 'external_user_idを作成してインスタンスのレコードを更新すること' do
        user.external_user_id = nil
        expect {
          user.get_or_create_external_user_id
        }.to change(user, :external_user_id)
      end
    end
  end

  describe '#post_tweet' do
    it 'Tweet出来ること' do
      twitter_client_mock = double('Twitter client')
      allow(twitter_client_mock).to receive(:update)
      allow(authenticated_user).to receive(:twitter_client).and_return(twitter_client_mock)
      expect{ authenticated_user.post_tweet('Post from Twitter API') }.not_to raise_error
    end
  end

  describe 'User.find_or_create_by_auth_hash' do
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

    context "uidを持つUserがレコードに存在するとき" do
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

    context "uidを持つUserがレコードに存在しないとき" do
      it 'uidを持つユーザを新規作成すること' do
        @auth_hash[:uid] = 'invalid_uid'
        expect {
          returned_user = User.find_or_create_by_auth_hash(@auth_hash)
          expect(returned_user).to_not eq authenticated_user
        }.to change(User, :count).by(1)
      end
    end
  end
end
