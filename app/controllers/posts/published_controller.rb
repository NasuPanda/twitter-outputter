class Posts::PublishedController < ApplicationController
  def index
    @published_posts = current_user.published_posts_by_recently_posted.
      page(params[:page]).per(10)
  end

  def create
    @post = current_user.posts.build(post_params)
    # NOTE: 新規作成の場合, タグ付けされたタグをcontentに追加しておく
    @post.add_tags_to_content(current_user.tagged_tags)
    if @post.save
      respond_to do |format|
        format.html { redirect_to root_url, notice: '投稿に成功しました' }
        format.js { @status = 'success' }
        # current_user.post_tweet(@post.content)
      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: '投稿に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end

  private

    def post_params
      params.require(:post).permit(:content)
    end
end
