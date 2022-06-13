require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'DELETE /posts/:id' do
    context 'from draft' do
      let!(:user) { FactoryBot.create(:user, :with_authentication) }
      let!(:draft) { FactoryBot.create(:post, :draft, user: user) }

      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
        end

        it '正常なレスポンスを返すこと' do
          delete post_path(draft, from: :draft), xhr: true
          expect(response).to have_http_status(:ok)
        end

        it '削除されること' do
          expect {
            delete post_path(draft, from: :draft), xhr: true
          }.to change{ user.drafts.count }.by(-1)
        end

        it '成功の通知が表示されること' do
          delete post_path(draft, from: :draft), xhr: true
          expect(response.body).to include('下書きの削除に成功しました')
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete post_path(draft, from: :draft), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '削除されないこと' do
          expect {
            delete post_path(draft, from: :draft), xhr: true
          }.to_not change{ user.drafts.count }
        end
      end

      context '正しくないユーザのとき' do
        let(:other_user) { FactoryBot.create(:user, :with_authentication) }

        before do
          sign_in_as(other_user)
        end

        it '404エラーが返ること' do
          delete post_path(draft, from: :draft), xhr: true
          expect(response).to have_http_status(404)
        end

        it '削除されないこと' do
          expect {
            delete post_path(draft, from: :draft), xhr: true
          }.to_not change{ user.drafts.count }
        end
      end
    end

    context 'from scheduled' do
      let!(:user) { FactoryBot.create(:user, :with_authentication) }
      let!(:scheduled_post) { FactoryBot.create(:post, :scheduled, user: user) }

      context 'ログインユーザのとき' do
        before do
          sign_in_as(user)
        end

        it '正常なレスポンスを返すこと' do
          delete post_path(scheduled_post, from: :scheduled), xhr: true
          expect(response).to have_http_status(:ok)
        end

        it '削除されること' do
          expect {
            delete post_path(scheduled_post, from: :scheduled), xhr: true
          }.to change{ user.scheduled_posts.count }.by(-1)
        end

        it '成功の通知が表示されること' do
          delete post_path(scheduled_post, from: :scheduled), xhr: true
          expect(response.body).to include('予約投稿の削除に成功しました')
        end
      end

      context '非ログインユーザのとき' do
        it 'rootにリダイレクトすること' do
          delete post_path(scheduled_post, from: :scheduled), xhr: true
          expect(response).to redirect_to(root_url)
        end

        it '削除されないこと' do
          expect {
            delete post_path(scheduled_post, from: :scheduled), xhr: true
          }.to_not change{ user.scheduled_posts.count }
        end
      end

      context '正しくないユーザのとき' do
        let(:other_user) { FactoryBot.create(:user, :with_authentication) }
        before do
          sign_in_as(other_user)
        end

        it '404エラーが返ること' do
          delete post_path(scheduled_post, from: :scheduled), xhr: true
          expect(response).to have_http_status(404)
        end

        it '削除されないこと' do
          expect {
            delete post_path(scheduled_post, from: :scheduled), xhr: true
          }.to_not change{ user.scheduled_posts.count }
        end
      end
    end
  end
end
