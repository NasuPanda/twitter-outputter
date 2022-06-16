require 'rails_helper'

RSpec.describe 'Posts::Scheduleds', type: :request do
  shared_context '予約投稿を持つ認証済のユーザ' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let(:scheduled_post) { FactoryBot.create(:post, :scheduled, user: user) }
  end

  describe 'GET /scheduled' do
    include_context '予約投稿を持つ認証済のユーザ'

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        get scheduled_index_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        get scheduled_index_path
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'POST /scheduled' do
    include_context '予約投稿を持つ認証済のユーザ'
    let(:valid_params) { FactoryBot.attributes_for(:post, :scheduled) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      context '有効なパラメータの場合' do
        it '作成されること' do
          expect {
            post scheduled_index_path, xhr: true, params: { post: valid_params }
          }.to change{ user.scheduled_posts.count }.by(1)
        end

        it '成功の通知が表示されること' do
          post scheduled_index_path, xhr: true, params: { post: valid_params }
          expect(response.body).to include('予約投稿に成功しました')
        end

        it '予約投稿ジョブがキューに入ること' do
          expect {
            post scheduled_index_path, xhr: true, params: { post: valid_params }
          }.to enqueue_job(ReservePostJob)
        end
      end

      context 'contentを入力していない場合' do
        it '作成されないこと' do
          expect {
            post scheduled_index_path, xhr: true,
            params: {
              post: {
                content: '',
                post_at: valid_params[:post_at]
              }
            }
          }.to_not change{ user.scheduled_posts.count }
        end

        it 'エラーメッセージが表示されること' do
          post scheduled_index_path, xhr: true,
          params: {
            post: {
              content: '',
              post_at: valid_params[:post_at]
            }
          }
          expect(response.body).to include('予約投稿に失敗しました')
        end

        it '予約投稿ジョブがキューに入らないこと' do
          expect {
            post scheduled_index_path, xhr: true,
            params: {
              post: {
                content: '',
                post_at: valid_params[:post_at]
              }
            }
          }.to_not enqueue_job(ReservePostJob)
        end
      end

      context '投稿日時を入力していない場合' do
        it '作成されないこと' do
          expect {
            post scheduled_index_path, xhr: true,
            params: {
              post: {
                content: valid_params[:content],
                post_at: nil
              }
            }
          }.to_not change{ user.scheduled_posts.count }
        end

        it 'エラーメッセージが表示されること' do
          post scheduled_index_path, xhr: true,
          params: {
            post: {
              content: valid_params[:content],
              post_at: nil
            }
          }
          expect(response.body).to include('予約投稿に失敗しました')
        end

        it '予約投稿ジョブがキューに入らないこと' do
          expect {
            post scheduled_index_path, xhr: true,
            params: {
              post: {
                content: valid_params[:content],
                post_at: nil
              }
            }
          }.to_not enqueue_job(ReservePostJob)
        end
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        post scheduled_index_path, xhr: true, params: { post: valid_params }
        expect(response).to redirect_to(root_url)
      end

      it '作成されないこと' do
        expect {
          post scheduled_index_path, xhr: true, params: { post: valid_params }
        }.to_not change{ user.scheduled_posts.count }
      end

      it '予約投稿ジョブがキューに入らないこと' do
        expect {
          post scheduled_index_path, xhr: true, params: { post: valid_params }
        }.to_not enqueue_job(ReservePostJob)
      end
    end
  end

  describe 'GET /scheduled/:id/edit' do
    include_context '予約投稿を持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        get edit_scheduled_path(scheduled_post), xhr: true
        expect(response).to have_http_status(:ok)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトすること' do
        get edit_scheduled_path(scheduled_post), xhr: true
        expect(response).to redirect_to root_url
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        get edit_scheduled_path(scheduled_post), xhr: true
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /scheduled/:id/edit' do
    include_context '予約投稿を持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }
    let(:valid_params) { FactoryBot.attributes_for(:post, :scheduled) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      context '有効なパラメータの場合' do
        it '更新されること' do
          content_before_update = scheduled_post.content

          expect {
            put scheduled_path(scheduled_post), xhr: true, params: { post: valid_params }
          }.to change{ scheduled_post.reload.content }
            .from(content_before_update).to(valid_params[:content])
        end

        it '成功の通知が表示されること' do
          put scheduled_path(scheduled_post), xhr: true, params: { post: valid_params }
          expect(response.body).to include('予約投稿の更新に成功しました')
        end
      end

      context 'contentが空の場合' do
        it '更新されないこと' do
          expect {
            put scheduled_path(scheduled_post), xhr: true,
            params: {
              post: {
                content: '',
                post_at: valid_params[:post_at]
              }
            }
          }.to_not change{ scheduled_post.reload.content }
        end

        it 'alertが表示されること' do
          put scheduled_path(scheduled_post), xhr: true,
          params: {
            post: {
              content: '',
              post_at: valid_params[:post_at]
            }
          }
          expect(response.body).to include('予約投稿の更新に失敗しました')
        end
      end

      context 'contentが長すぎる場合' do
        it '更新されないこと' do
          expect {
            put scheduled_path(scheduled_post), xhr: true,
            params: {
              post: {
                content: 'あ' * 141,
                post_at: valid_params[:post_at]
              }
            }
          }.to_not change{ scheduled_post.reload.content }
        end

        it 'alertが表示されること' do
          put scheduled_path(scheduled_post), xhr: true,
          params: {
            post: {
              content: 'あ' * 141,
              post_at: valid_params[:post_at]
            }
          }
          expect(response.body).to include('予約投稿の更新に失敗しました')
        end
      end

      context 'post_atが存在しない場合' do
        it '更新されないこと' do
          expect {
            put scheduled_path(scheduled_post), xhr: true,
            params: {
              post: {
                content: valid_params[:content],
                post_at: nil
              }
            }
          }.to_not change{ scheduled_post.reload.content }
        end
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトすること' do
        put scheduled_path(scheduled_post), xhr: true, params: valid_params
        expect(response).to redirect_to(root_url)
      end

      it '更新されないこと' do
        expect {
          put scheduled_path(scheduled_post), xhr: true, params: valid_params
        }.to_not change{ scheduled_post.reload }
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        put scheduled_path(scheduled_post), xhr: true, params: valid_params
        expect(response).to have_http_status(404)
      end

      it '更新されないこと' do
        expect {
          put scheduled_path(scheduled_post), xhr: true, params: valid_params
        }.to_not change{ scheduled_post.reload }
      end
    end
  end

  describe 'DELETE GET /scheduled/:id' do
    include_context '予約投稿を持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'to published' do
      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
          # TwitterAPIのモック化
          twitter_mock
        end

        it '投稿済になること' do
          expect {
            delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          }.to change{ scheduled_post.reload.status }.from('scheduled').to('published')
        end

        it '成功の通知が表示されること' do
          delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          expect(response.body).to include('投稿に成功しました')
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '投稿済にならないこと' do
          expect {
            delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          }.to_not change{ scheduled_post.reload.status }
        end
      end

      context '正しくないユーザのとき' do
        before do
          sign_in_as(other_user)
        end

        it '404エラーが返ること' do
          delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          expect(response).to have_http_status(404)
        end

        it '投稿済にならないこと' do
          expect {
            delete scheduled_path(scheduled_post, to: 'published'), xhr: true
          }.to_not change{ scheduled_post.reload.status }
        end
      end
    end

    context 'to draft' do
      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
        end

        it '下書きになること' do
          expect {
            delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          }.to change{ scheduled_post.reload.status }.from('scheduled').to('draft')
        end

        it '成功の通知が表示されること' do
          delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          expect(response.body).to include('予約投稿の取り消しに成功しました')
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '投稿済にならないこと' do
          expect {
            delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          }.to_not change{ scheduled_post.reload.status }
        end
      end

      context '正しくないユーザのとき' do
        before do
          sign_in_as(other_user)
        end

        it '404エラーが返ること' do
          delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          expect(response).to have_http_status(404)
        end

        it '投稿済にならないこと' do
          expect {
            delete scheduled_path(scheduled_post, to: 'draft'), xhr: true
          }.to_not change{ scheduled_post.reload.status }
        end
      end
    end
  end
end
