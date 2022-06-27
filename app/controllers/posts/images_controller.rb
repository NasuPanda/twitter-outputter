class Posts::ImagesController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  # 画像を削除する
  def destroy
    pp current_user.posts.find(188)
    pp "params: #{image_params}"
    post = current_user.posts.find(image_params[:post_id])
    @image = post.images.find(image_params[:id])

    if @image.destroy
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '画像の削除に成功しました' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '画像の削除に失敗しました' }
        format.js { @error_messages = error_messages_with_prefix(@image, '画像の削除に失敗しました') }
      end
    end
  end

  private

    def image_params
      params.permit(:id, :post_id)
    end
end
