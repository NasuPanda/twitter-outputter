class SetScheduledJob < ApplicationJob
  queue_as :default

  def perform(post_id, post_updated_at)
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
    begin
      user.post_tweet(post.content)
    rescue Twitter::Error::DuplicateStatus
      p "重複した投稿"
      # TODO 予約投稿の失敗を表すstatsuを追加する
    end
    p "*" * 50
  end
end
