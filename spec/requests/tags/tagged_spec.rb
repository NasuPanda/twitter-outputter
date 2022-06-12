require 'rails_helper'

RSpec.describe 'Tags::Tagged', type: :request do
  shared_context 'タグを持つ認証済みのユーザ' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let(:tag) { FactoryBot.create(:tag, user: user) }
    let(:tagged_tag) { FactoryBot.create(:tag, :tagged, user: user) }
  end

  describe 'POST /tagged' do
    include_context 'タグを持つ認証済みのユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        post tagged_index_path(id: tag.id), xhr: true
        expect(response).to have_http_status(:ok)
      end

      it 'tag.is_taggedがtrueになること' do
        expect{
          post tagged_index_path(id: tag.id), xhr: true
        }.to change{ tag.reload.is_tagged }.from(false).to(true)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        post tagged_index_path(id: tag.id), xhr: true
        expect(response).to redirect_to root_url
      end

      it 'tag.is_taggedが変化しないこと' do
        expect{
          post tagged_index_path(id: tag.id), xhr: true
        }.to_not change{ tag.reload.is_tagged }
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        post tagged_index_path(id: tag.id), xhr: true
        expect(response).to have_http_status(404)
      end

      it 'tag.is_taggedが変化しないこと' do
        expect{
          post tagged_index_path(id: tag.id), xhr: true
        }.to_not change{ tag.reload.is_tagged }
      end
    end

    context 'Ajax以外のリクエストのとき' do
      before do
        sign_in_as(user)
      end

      it '404エラーが返ること' do
        post tagged_index_path(id: tag.id)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /tagged/:id' do
    include_context 'タグを持つ認証済みのユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        delete tagged_path(tagged_tag), xhr: true
        expect(response).to have_http_status(:ok)
      end

      it 'tag.is_taggedがfalseになること' do
        expect{
          delete tagged_path(tagged_tag), xhr: true
        }.to change{ tagged_tag.reload.is_tagged }.from(true).to(false)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        delete tagged_path(tagged_tag), xhr: true
        expect(response).to redirect_to root_url
      end

      it 'tag.is_taggedが変化しないこと' do
        expect{
          delete tagged_path(tagged_tag), xhr: true
        }.to_not change{ tag.reload.is_tagged }
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        delete tagged_path(tagged_tag), xhr: true
        expect(response).to have_http_status(404)
      end

      it 'tag.is_taggedが変化しないこと' do
        expect{
          delete tagged_path(tagged_tag), xhr: true
        }.to_not change{ tag.reload.is_tagged }
      end
    end

    context 'Ajax以外のリクエストのとき' do
      before do
        sign_in_as(user)
      end

      it '404エラーが返ること' do
        delete tagged_path(tagged_tag)
        expect(response).to have_http_status(404)
      end
    end
  end
end
