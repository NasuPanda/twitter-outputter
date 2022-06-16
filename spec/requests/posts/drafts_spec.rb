require 'rails_helper'

RSpec.describe 'Posts::Drafts', type: :request do
  shared_context '下書きを持つ認証済のユーザ' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let(:draft) { FactoryBot.create(:post, :draft, user: user) }
  end

  describe 'GET /drafts' do
    include_context '下書きを持つ認証済のユーザ'

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        get drafts_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        get drafts_path
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'POST /drafts' do
    include_context '下書きを持つ認証済のユーザ'

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      context '有効なパラメータの場合' do
        it '作成されること' do
          expect {
            post drafts_path, xhr: true, params: { post: { content: 'test content' } }
          }.to change{ user.drafts.count }.by(1)
        end

        it '成功の通知が表示されること' do
          post drafts_path, xhr: true, params: { post: { content: 'test content' } }
          expect(response.body).to include('下書きの保存に成功しました')
        end
      end

      context 'contentを入力していない場合' do
        it '作成されないこと' do
          expect {
            post drafts_path, xhr: true, params: { post: { content: '' } }
          }.to_not change{ user.drafts.count }
        end

        it 'エラーメッセージが表示されること' do
          post drafts_path, xhr: true, params: { post: { content: '' } }
          expect(response.body).to include('下書きの保存に失敗しました')
        end
      end

      context 'contentが長すぎる場合' do
        it '作成されないこと' do
          expect {
            post drafts_path, xhr: true, params: { post: { content: 'あ' * 141 } }
          }.to_not change{ user.drafts.count }
        end

        it 'エラーメッセージが表示されること' do
          post drafts_path, xhr: true, params: { post: { content: 'あ' * 141 } }
          expect(response.body).to include('下書きの保存に失敗しました')
        end
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        post drafts_path, xhr: true, params: { post: { content: 'test content' } }
        expect(response).to redirect_to(root_url)
      end

      it '作成されないこと' do
        expect {
          post drafts_path, xhr: true, params: { post: { content: 'test content' } }
        }.to_not change{ user.drafts.count }
      end
    end
  end

  describe 'GET /drafts/:id/edit' do
    include_context '下書きを持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスを返すこと' do
        get edit_draft_path(draft), xhr: true
        expect(response).to have_http_status(:ok)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトすること' do
        get edit_draft_path(draft), xhr: true
        expect(response).to redirect_to(root_url)
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        get edit_draft_path(draft), xhr: true
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /drafts/:id/edit' do
    include_context '下書きを持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      context '有効なパラメータの場合' do
        it '更新されること' do
          before_update = draft.content

          expect {
            put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
          }.to change{ draft.reload.content }.from(before_update).to('updated')
        end

        it '成功の通知が表示されること' do
          put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
          expect(response.body).to include('下書きの更新に成功しました')
        end
      end

      context 'contentを入力していない場合' do
        it '更新されないこと' do
          expect {
            put draft_path(draft), xhr: true, params: { post: { content: '' } }
          }.to_not change{ draft.reload.content }
        end

        it 'alertが表示されること' do
          put draft_path(draft), xhr: true, params: { post: { content: '' } }
          expect(response.body).to include('下書きの更新に失敗しました')
        end
      end

      context 'contentが長すぎる場合' do
        it '更新されないこと' do
          expect {
            put draft_path(draft), xhr: true, params: { post: { content: 'あ' * 141 } }
          }.to_not change{ draft.reload.content }
        end

        it 'alertが表示されること' do
          put draft_path(draft), xhr: true, params: { post: { content: 'あ' * 141 } }
          expect(response.body).to include('下書きの更新に失敗しました')
        end
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトすること' do
        put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
        expect(response).to redirect_to(root_url)
      end

      it '更新されないこと' do
        expect {
          put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
        }.to_not change{ draft.reload.content }
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it '404エラーが返ること' do
        put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
        expect(response).to have_http_status(404)
      end

      it '更新されないこと' do
        expect{
          put draft_path(draft), xhr: true, params: { post: { content: 'updated' } }
        }.to_not change{ draft.reload.content }
      end
    end
  end

  describe 'DELETE /drafts/:id' do
    include_context '下書きを持つ認証済のユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'to published' do
      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
          twitter_mock
        end

        it '投稿済になること' do
          expect {
            delete draft_path(draft, to: 'published'), xhr: true
          }.to change{ draft.reload.status }.from('draft').to('published')
        end

        it '成功の通知が表示されること' do
          delete draft_path(draft, to: 'published'), xhr: true
          expect(response.body).to include('投稿に成功しました')
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete draft_path(draft, to: 'published'), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '投稿済にならないこと' do
          expect {
            delete draft_path(draft, to: 'published'), xhr: true
          }.to_not change{ draft.reload.status }
        end
      end

      context '正しくないユーザのとき' do
        before do
          sign_in_as(other_user)
        end

        it '404エラーが返ること' do
          delete draft_path(draft, to: 'published'), xhr: true
          expect(response).to have_http_status(404)
        end

        it '投稿済にならないこと' do
          expect {
            delete draft_path(draft, to: 'published'), xhr: true
          }.to_not change{ draft.reload.status }
        end
      end
    end

    context 'to scheduled' do
      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
        end

        context '投稿日時が有効なとき' do
          before do
            draft.update(post_at: 1.days.from_now)
          end

          it '投稿の予約に成功すること' do
            expect {
              delete draft_path(draft, to: 'scheduled'), xhr: true
            }.to change{ draft.reload.status }.from('draft').to('scheduled')
          end

          it '成功の通知が表示されること' do
            delete draft_path(draft, to: 'scheduled'), xhr: true
            expect(response.body).to include('予約投稿に成功しました')
          end

          it '予約投稿ジョブがキューに入ること' do
            expect {
              delete draft_path(draft, to: 'scheduled'), xhr: true
            }.to enqueue_job(ReservePostJob)
          end
        end

        context '投稿日時が無効なとき' do
          before do
            draft.update(post_at: nil)
          end

          it '投稿の予約に失敗すること' do
            expect {
              delete draft_path(draft, to: 'scheduled'), xhr: true
            }.to_not change{ draft.reload.status }
          end

          it '予約投稿ジョブがキューに入らないこと' do
            expect {
              delete draft_path(draft, to: 'scheduled'), xhr: true
            }.to_not enqueue_job(ReservePostJob)
          end
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete draft_path(draft, to: 'scheduled'), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '投稿の予約に失敗すること' do
          expect {
            delete draft_path(draft, to: 'scheduled'), xhr: true
          }.to_not change{ draft.reload.status }
        end

        it '予約投稿ジョブがキューに入らないこと' do
          expect {
            delete draft_path(draft, to: 'scheduled'), xhr: true
          }.to_not enqueue_job(ReservePostJob)
        end
      end

      context '正しくないユーザのとき' do
        before do
          sign_in_as(other_user)
          draft.update(post_at: 1.days.from_now)
        end

        it '404エラーが返ること' do
          delete draft_path(draft, to: 'scheduled'), xhr: true
          expect(response).to have_http_status(404)
        end

        it '投稿の予約に失敗すること' do
          expect {
            delete draft_path(draft, to: 'scheduled'), xhr: true
          }.to_not change{ draft.reload.status }
        end

        it 'ジョブがキューに入らないこと' do
          expect {
            delete draft_path(draft, to: 'scheduled'), xhr: true
          }.to_not enqueue_job(ReservePostJob)
        end
      end
    end
  end
end
