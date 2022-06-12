class Posts::PublishedController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  def index
    @published_posts = current_user.published_posts_by_recently_posted.
      page(params[:page]).per(10)
  end

  def create
    @published_post = build_published_post
    if @published_post.save
      respond_to do |format|
        format.html { redirect_to root_url, notice: '投稿に成功しました' }
        format.js do
          @error_messages = []
          @action = 'published'
        end
        # current_user.post_tweet(@published_post.content)
      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: '投稿に失敗しました。' }
        format.js { @error_messages = @published_post.errors.full_messages.prepend('投稿に失敗しました。') }
      end
    end
  end

  private

    def post_params
      params.require(:post).permit(:content)
    end

    def build_published_post
      published_post = current_user.posts.build(post_params)
      # NOTE: 新規作成の場合, タグ付けされたタグをcontentに追加しておく
      published_post.add_tags_to_content(current_user.tagged_tags)
      published_post.to_published
      return published_post
    end
end
