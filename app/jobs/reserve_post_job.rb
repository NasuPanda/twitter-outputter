class ReservePostJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5

  def perform(user, post_id, post_updated_at)
    post = Post.find(post_id)

    # 更新日時が異なる場合は実行しない
    if post_updated_at.round(0) != post.updated_at.round(0)
      p "*" * 50
      p "doesn't work!!"
      p "*" * 50
      return
    end

    p "*" * 50
    p "Perform!"
    p "*" * 50
    begin
      user.post_tweet(post.content)
    rescue Twitter::Error::DuplicateStatus
      p "重複した投稿"
      post.scheduled_post_job.failure!
    end
  end
end
