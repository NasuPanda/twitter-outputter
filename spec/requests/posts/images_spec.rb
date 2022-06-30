require 'rails_helper'

RSpec.describe "Posts::Images", type: :request do
  describe 'DELETE posts/images/:id' do
    context 'ログインユーザのとき' do
      let!(:user) { FactoryBot.create(:user, :with_authentication) }
      let!(:post_with_image) { FactoryBot.create(:post, :with_image, user: user) }
      let!(:image) { post_with_image.images.first }

      before { sign_in_as(user) }

      it '画像を削除出来ること' do
        expect{
          delete posts_image_path(image, post_id: post_with_image.id), xhr: true
        }.to change{ post_with_image.images.count }.by(-1)
      end
    end

    context 'ログインしていないユーザのとき' do
      let!(:post_with_image) { FactoryBot.create(:post, :with_image) }
      let!(:image) { post_with_image.images.first }

      it '画像を削除出来ないこと' do
        expect{
          delete posts_image_path(image, post_id: post_with_image.id), xhr: true
        }.to_not change{ post_with_image.images.count }
      end

      it 'rootにリダイレクトされること' do
        delete posts_image_path(image, post_id: post_with_image.id), xhr: true
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
