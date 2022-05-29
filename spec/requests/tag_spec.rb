require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  shared_context 'タグを持つ認証済みのユーザ' do
    let!(:user) { FactoryBot.create(:user, :with_authentication, :with_tag) }
    let!(:tag) { user.tags.last }
  end

  describe 'GET tags/new' do
    let(:user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスが返ること' do
        # NOTE: Ajaxなので xhr: true を付けること
        get new_tag_path, xhr: true
        expect(response).to have_http_status :ok
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        get new_tag_path, xhr: true
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'POST /tags' do
    let(:user) { FactoryBot.create(:user, :with_authentication) }
    let(:tag_params) {
      { tag: { name: 'test tag' } }
    }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '作成できること' do
        expect {
          post tags_path, xhr: true, params: tag_params
        }.to change{ Tag.count }.by(1)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        post tags_path, xhr: true, params: tag_params
        expect(response).to redirect_to root_url
      end

      it '作成できないこと' do
        expect {
          post tags_path, xhr: true, params: tag_params
        }.to_not change{ Tag.count }
      end
    end
  end

  describe 'GET tags/:id/edit' do
    include_context 'タグを持つ認証済みのユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '正常なレスポンスが返ること' do
        get edit_tag_path(tag), xhr: true
        expect(response).to have_http_status :ok
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        get edit_tag_path(tag), xhr: true
        expect(response).to redirect_to root_url
      end
    end

    context '正しくないユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it 'rootにリダイレクトされること' do
        get edit_tag_path(tag), xhr: true
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'PATCH /tags/:id' do
    include_context 'タグを持つ認証済みのユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }
    let(:tag_params) {
      { tag: { name: 'updated tag' } }
    }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '更新できること' do
        patch tag_path(tag), xhr: true, params: tag_params
        expect(tag.reload.name).to eq tag_params[:tag][:name]
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        patch tag_path(tag), xhr: true, params: tag_params
        expect(response).to redirect_to root_url
      end

      it '更新できないこと' do
        patch tag_path(tag), xhr: true, params: tag_params
        expect(tag.reload.name).to_not eq tag_params[:tag][:name]
      end
    end

    context '他のユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it 'rootにリダイレクトされること' do
        patch tag_path(tag), xhr: true, params: tag_params
        expect(response).to redirect_to root_url
      end

      it '更新できないこと' do
        patch tag_path(tag), xhr: true, params: tag_params
        expect(tag.reload.name).to_not eq tag_params[:tag][:name]
      end
    end
  end

  describe 'DELETE /tags/:id' do
    include_context 'タグを持つ認証済みのユーザ'
    let(:other_user) { FactoryBot.create(:user, :with_authentication) }

    context 'ログインユーザのとき' do
      before do
        sign_in_as(user)
      end

      it '削除できること' do
        expect {
          delete tag_path(tag), xhr: true
        }.to change{ Tag.count }.by(-1)
      end
    end

    context '非ログインユーザのとき' do
      it 'rootにリダイレクトされること' do
        delete tag_path(tag), xhr: true
        expect(response).to redirect_to root_url
      end

      it '削除できないこと' do
        expect {
          delete tag_path(tag), xhr: true
        }.to_not change{ Tag.count }
      end
    end

    context '他のユーザのとき' do
      before do
        sign_in_as(other_user)
      end

      it 'rootにリダイレクトされること' do
        delete tag_path(tag), xhr: true
        expect(response).to redirect_to root_url
      end

      it '削除できないこと' do
        expect {
          delete tag_path(tag), xhr: true
        }.to_not change{ Tag.count }
      end
    end
  end
end
