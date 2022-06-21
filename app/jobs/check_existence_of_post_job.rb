class CheckExistenceOfPostJob < ApplicationJob
  queue_as :check_post

  after_perform { |job| perform_again(job) }

  def perform(user)
    tweet = user.most_recent_tweet
    if tweet && tweet_exist?(user, tweet)
      # 何もしない
      puts 'tweet exist!'
    else
      # TODO OneSignalでPush通知する
      puts 'tweet does not exist!'
    end
  end

  private

    # 再度ジョブを登録する
    def perform_again(job)
      user = job.arguments[0]
      self.class.set(
        wait_until: user.notification_setting.check_tweet_existence_time
      ).perform_later(user)
    end

    # 特定期間にツイートが存在するかチェック
    def tweet_exist?(user, tweet)
      tweet.created_at.in_time_zone('Tokyo').between?(
        *user.notification_setting.check_tweet_existence_range
      )
    end
end
