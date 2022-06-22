class CheckExistenceOfPostJob < ApplicationJob
  queue_as :check_post

  # after_perform { |job| perform_again(job) }

  def perform(user)
    tweet = user.most_recent_tweet
    unless tweet && tweet_exist_in_period?(tweet, *user.notification_setting.check_tweet_existence_range)
      # OneSignalでPush通知する
      puts 'tweet does not exist!'
      CreateNotification.call(
        contents: notification_message(*user.notification_setting.check_tweet_existence_range),
        type: 'posts#create',
        external_user_id: user.external_user_id
      )
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
    def tweet_exist_in_period?(tweet, from, to)
      tweet.created_at.in_time_zone('Tokyo').between?(from, to)
    end

    # 通知するメッセージ
    def notification_message(from, to)
      {
        'en': "You forget a tweet!",
        'ja': "投稿を忘れています!\n期間: #{I18n.l(from, format: :short)} ~ #{I18n.l(to, format: :short)}"
      }
    end
end
