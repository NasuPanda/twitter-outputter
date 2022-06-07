class PostsController < ApplicationController
  def destroy
    @post = current_user.posts.find(params[:id])
    # TODO 実装する
    @post.destroy
  end
end
