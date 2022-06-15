module Tweetable
  extend ActiveSupport::Concern

  # ツイートする
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

    # ツイートを予約する
    def reserve_tweet(post)
      job = ReservePostJob.set(wait_until: post.post_at).perform_later(current_user, post.id, post.updated_at)
      post.create_scheduled_post_job(job_id: job.provider_job_id)
    end

    # 予約ツイートを更新する
    def update_scheduled_tweet(post)
      job = ReservePostJob.set(wait_until: post.post_at).perform_later(current_user, post.id, post.updated_at)
      post.scheduled_post_job.update(job_id: job.provider_job_id)
    end

    # 予約ツイートをキャンセルする
    def cancel_scheduled_tweet(post)
      post.scheduled_post_job.destroy!
    end
end