class PostsController < ApplicationController
  # postそのものを削除する
  def destroy
    @post = current_user.posts.find(params[:id])
    # TODO 下書き, 予約投稿の削除に両対応する
    if @post.destroy
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの削除に成功しました' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの削除に失敗しました' }
        format.js { @error_messages = @post.errors.full_messages.prepend('下書きの削除に失敗しました') }
      end
    end
  end

  private

    def post_params
      params.require(:post).permit(:content, :post_at)
    end
end
