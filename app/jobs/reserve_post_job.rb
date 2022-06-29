class ReservePostJob < ApplicationJob
  queue_as :default

  def perform(user, post_id, post_updated_at)
    # 更新日時が異なる場合は実行しない
    post = Post.find(post_id)
    # NOTE: DB側とジョブ側で小数点精度が異なるため丸める
    if post_updated_at.to_f.floor != post.updated_at.to_f.floor
      return
    end

    return unless post_tweet(user, post)

    # Postのstatus, post_atを更新
    to_published(post)
  end

  def post_tweet(user, post)
    begin
      user.post_tweet(post)
    # 重複した投稿の場合
    rescue Twitter::Error::DuplicateStatus
      post.scheduled_post_job.failure!
      return
    end

    return true
  end

  def to_published(post)
    post.to_published
    post.scheduled_post_job.destroy!
    post.save!
  end
end
