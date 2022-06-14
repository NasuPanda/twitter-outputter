module Tweetable
  extend ActiveSupport::Concern

  def post_tweet(post)
    return unless post.valid?

    begin
      current_user.post_tweet(post.content)
    # Twitter::Error::UnauthorizedはErrorsControllerで拾う
    rescue Twitter::Error::DuplicateStatus
      redirect_to root_url, alert: '投稿に失敗しました。過去に同じ投稿をしています。' and return
    end

    return true
  end
end