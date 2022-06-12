class PostsController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  # postそのものを削除する
  def destroy
    @post = current_user.posts.find(params[:id])

    # from 下書き/予約投稿 で分岐する
    if params[:from] == 'draft'
      destroy_draft
    elsif params[:from] == 'scheduled'
      destroy_scheduled_post
    else
      # TODO エラー投げる
    end
  end

  private

    def post_params
      params.require(:post).permit(:content, :post_at)
    end

    # 下書きを削除する
    def destroy_draft
      if @post.destroy
        respond_to do |format|
          format.html { redirect_to drafts_url, notice: '下書きの削除に成功しました' }
          format.js do
            @error_messages = []
            @from = 'draft'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to drafts_url, notice: '下書きの削除に失敗しました' }
          format.js { @error_messages = error_messages_with_prefix(@post, '下書きの削除に失敗しました') }
        end
      end
    end

    # 予約投稿を削除する
    def destroy_scheduled_post
      # TODO ジョブの削除
      if @post.destroy
        respond_to do |format|
          format.html { redirect_to drafts_url, notice: '予約投稿の削除に成功しました' }
          format.js do
            @error_messages = []
            @from = 'scheduled'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to drafts_url, notice: '予約投稿の削除に失敗しました' }
          format.js { @error_messages = error_messages_with_prefix(@post, '予約投稿の削除に失敗しました') }
        end
      end
    end
end
