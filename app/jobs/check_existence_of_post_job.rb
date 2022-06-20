class CheckExistenceOfPostJob < ApplicationJob
  queue_as :check_post

  after_perform { |job| perform_again(job) }

  # TODO
  # Setting#update時にジョブを走らせる
    # NOTE: 前回のJobIDを保持する必要があるのでSettingがJobモデルを持つか, Settingモデルにjob_idカラムを付け足すか
    # 通知機能がONになったらという分岐が必要
    # OFFならば削除する
  # ジョブの実行結果によってはOneSignalで通知する

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
