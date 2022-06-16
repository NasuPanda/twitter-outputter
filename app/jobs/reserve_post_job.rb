class ReservePostJob < ApplicationJob
  queue_as :default

  def perform(user, post_id, post_updated_at)
    post = Post.find(post_id)

    # 更新日時が異なる場合は実行しない
    if post_updated_at.to_f.floor != post.updated_at.to_f.floor
      p "*" * 50
      p "doesn't work!!"
      p "*" * 50
      return
    end

    p "*" * 50
    p "Perform!"
    p "*" * 50
    post_tweet(user, post)
  end

  def post_tweet(user, post)
    begin
      user.post_tweet(post.content)
    # 重複した投稿の場合
    rescue Twitter::Error::DuplicateStatus
      post.scheduled_post_job.failure!
    end
  end
end
