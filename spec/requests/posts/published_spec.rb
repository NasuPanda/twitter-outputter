require 'rails_helper'

RSpec.describe 'Posts::Publisheds', type: :request do
  shared_context '公開済の投稿を持つ認証済のユーザ' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let(:published_post) { FactoryBot.create(:post, :published, user: user) }
  end

  describe 'GET /published' do
    include_context '公開済の投稿を持つ認証済のユーザ'

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        get published_index_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        get published_index_path
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'POST /published' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
        # twitterAPIをモック化
        twitter_mock
      end

      context '有効なパラメータの場合' do
        it '作成されること' do
          expect {
            post published_index_path, xhr: true, params: { post: { content: 'test content' } }
          }.to change{ user.published_posts.count }.by(1)
        end

        it '成功の通知が表示されること' do
          post published_index_path, xhr: true, params: { post: { content: 'test content' } }
          expect(response.body).to include('投稿に成功しました')
        end
      end

      context 'contentが入力されていない場合' do
        it '作成されないこと' do
          expect {
            post published_index_path, xhr: true, params: { post: { content: '' } }
          }.to_not change{ user.published_posts.count }
        end

        it 'エラーメッセージが表示されること' do
          post published_index_path, xhr: true, params: { post: { content: '' } }
          expect(response.body).to include('投稿に失敗しました')
        end
      end

      context 'contentが長すぎる場合' do
        it '作成されないこと' do
          expect {
            post published_index_path, xhr: true, params: { post: { content: 'あ' * 141 } }
          }.to_not change{ user.published_posts.count }
        end

        it 'エラーメッセージが表示されること' do
          post published_index_path, xhr: true, params: { post: { content: 'あ' * 141 } }
          expect(response.body).to include('投稿に失敗しました')
        end
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        post published_index_path, xhr: true, params: { post: { content: 'test content' } }
        expect(response).to redirect_to root_url
      end

      it '作成されないこと' do
        expect {
          post published_index_path, xhr: true, params: { post: { content: 'test content' } }
        }.to_not change{ user.published_posts.count }
      end
    end
  end
end
