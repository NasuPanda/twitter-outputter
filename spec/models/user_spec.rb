require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションのテスト' do
    let(:user) { FactoryBot.create(:user) }
    context '有効な属性のとき' do
      it 'バリデーションに成功すること' do
        expect(user).to be_valid
      end

    end
  end

  describe 'scopeのテスト' do
    describe 'User.find_authentication_uid' do
      let!(:authenticated_user) { FactoryBot.create(:user, :with_authentication) }

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
  end

  describe 'メソッドのテスト' do
    describe '#find_or_create_external_user_id' do
      let(:user) { FactoryBot.create(:user) }
      let(:user_without_external_user_id) { FactoryBot.create(:user, :without_external_user_id) }

      context 'インスタンスがexternal_user_idを持っているとき' do
        it 'インスタンスが持つexternal_user_idを返すこと' do
          expect(user.find_or_create_external_user_id).to eq user.external_user_id
        end
      end

      context "インスタンスがexternal_user_idを持たないとき" do
        it 'external_user_idを作成してインスタンスのレコードを更新すること' do
          expect {
            user_without_external_user_id.find_or_create_external_user_id
          }.to change(user_without_external_user_id, :external_user_id)
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

      context "uidを持つUserがレコードに存在するとき" do
        it 'uidを持つユーザを返すこと' do
          returned_user = User.find_or_create_by_auth_hash(@auth_hash)
          expect(returned_user).to eq authenticated_user
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
end
