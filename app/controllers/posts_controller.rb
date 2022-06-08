class PostsController < ApplicationController
  def destroy
    @post = current_user.posts.find(params[:id])
    if @post.destroy
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの削除に成功しました' }
        format.js { @status = 'success' }
      end
    else
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの削除に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end
end
