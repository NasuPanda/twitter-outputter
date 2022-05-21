class TwitterController < ApplicationController
  def update
    current_user.post_tweet("Post from Rails twitter API (another user)")
  end
end