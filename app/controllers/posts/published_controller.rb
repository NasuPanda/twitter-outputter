class Posts::PublishedController < ApplicationController
  def index
    @published_posts = current_user.published_posts
  end

  def create
  end
end
