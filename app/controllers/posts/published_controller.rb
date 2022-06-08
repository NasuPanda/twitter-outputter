class Posts::PublishedController < ApplicationController
  def index
    @published_posts = current_user.published_posts_by_recently_posted.
      page(params[:page]).per(10)
  end

  def create
    # TODO 投稿する処理
    # current_user.post_tweet
  end
end
