class Posts::PublishedController < ApplicationController
  def index
    @published_posts = current_user.published_posts_by_recently_posted.
      page(params[:page]).per(10)
  end

  private

    def post_params
      params.require(:post).permit(:content, :post_at)
    end
end
