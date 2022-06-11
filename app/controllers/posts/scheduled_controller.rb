class Posts::ScheduledController < ApplicationController
  def index
    @scheduled_posts  = current_user.scheduled_posts_by_recently_posting
      .page(params[:page]).per(10)
  end

  def create
    @scheduled_post = build_scheduled_post
    if @scheduled_post.save
      respond_to do |format|
        format.html { redirect_to root_url, notice: "予約投稿に成功しました: 予約日時#{l(post.post_at, format: :short)}" }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: '予約投稿に失敗しました。' }
        format.js { @error_messages = @scheduled_post.errors.full_messages.prepend('予約投稿に失敗しました。') }
      end
    end
  end

  def edit
    @scheduled_post = current_user.scheduled_posts.find(params[:id])
  end

  def update
    @scheduled_post = current_user.scheduled_posts.find(params[:id])
    if @scheduled_post.update(scheduled_params)
      respond_to do |format|
        format.html { redirect_to published_index_path, notice: '予約投稿の更新に成功しました' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to published_index_path, notice: '予約投稿の更新に失敗しました' }
        format.js { @error_messages = error_messages_with_prefix(@scheduled_post, '予約投稿の更新に失敗しました。') }
      end
    end
  end

  # NOTE: 予約投稿から削除 → 下書き or 投稿へ
  def destroy
    @scheduled_post = current_user.scheduled_posts.find(params[:id])
    @scheduled_post.to_published
    # TODO current_user.post_tweet
    if @scheduled_post.save
      format.html { redirect_to published_index_path, notice: '投稿に成功しました' }
      format.js { @error_messages = [] }
    else
    end
  end

  private

    def scheduled_params
      params.require(:post).permit(:content, :post_at)
    end

    # paramsを元にPostを生成する
    def build_scheduled_post
      scheduled_post = current_user.posts.build(scheduled_params)
      # NOTE: 新規作成の場合, タグ付けされたタグをcontentに追加しておく
      scheduled_post.add_tags_to_content(current_user.tagged_tags)
      scheduled_post.to_scheduled
      return scheduled_post
    end
end
