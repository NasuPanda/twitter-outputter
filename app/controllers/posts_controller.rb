class PostsController < ApplicationController
  def create
    # post_atが存在しない(=設定されていない)場合は投稿
    if post_params[:post_at].blank?
      create_published_post
    # post_atが存在する(=設定されている)場合は予約投稿
    else
      create_scheduled_post
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    # TODO 下書き以外にも対応
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

    # paramsを元にPostを生成する
    def build_post
      @post = current_user.posts.build(post_params)
      # NOTE: 新規作成の場合, タグ付けされたタグをcontentに追加しておく
      @post.add_tags_to_content(current_user.tagged_tags)
    end

    # 投稿する
    def create_published_post
      build_post
      @post.to_published
      if @post.save
        respond_to do |format|
          format.html { redirect_to root_url, notice: '投稿に成功しました' }
          format.js do
            @error_messages = []
            @action = 'published'
          end
          # current_user.post_tweet(@post.content)
        end
      else
        respond_to do |format|
          format.html { redirect_to root_url, alert: '投稿に失敗しました。' }
          format.js { @error_messages = @post.errors.full_messages.prepend('投稿に失敗しました。') }
        end
      end
    end

    # 予約投稿する
    def create_scheduled_post
      build_post
      @post.to_scheduled
      if @post.save
        respond_to do |format|
          format.html { redirect_to root_url, notice: "予約投稿に成功しました: 予約日時#{l(post.post_at, format: :short)}" }
          format.js do
            @error_messages = []
            @action = 'scheduled'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to root_url, alert: '予約投稿に失敗しました。' }
          format.js { @error_messages = @post.errors.full_messages.prepend('予約投稿に失敗しました。') }
        end
      end
    end
end
