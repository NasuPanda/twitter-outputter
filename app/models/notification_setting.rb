class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :can_notify, inclusion: [true, false]
  validates :notify_at, presence: true, if: Proc.new { |setting| setting.can_notify? }
  validate :interval_to_check_should_be_within_a_month, if: Proc.new { |setting| setting.can_notify? }

  has_one :check_tweet_job, dependent: :destroy

  # ツイート有無を確認する期間 N日前/今日かつ時刻がnotify_atのTimeWithZoneを返す
  def check_tweet_existence_range
    return unless can_notify?

    min_day = interval_to_check.days.ago
    max_day = Time.current
    return min_day.change(min: notify_min, hour: notify_hour), max_day.change(min: notify_min, hour: notify_hour)
  end

  # ツイート有無を確認するタイミング N日後かつ時刻がnotify_atのTimeWithZoneを返す
  def check_tweet_existence_time
    return unless can_notify?

    interval_to_check.days.from_now.change(min: notify_min, hour: notify_hour)
  end

  # ジョブをセットする
  def set_check_tweet_job
    job = perform_later_check_tweet_job
    self.create_check_tweet_job(job_id: job.provider_job_id)
  end

  private
    # バリデーション(can_notifyのとき) : interval_to_checkが0~30の間であること
    def interval_to_check_should_be_within_a_month
      unless interval_to_check.between?(0, 30)
        errors[:interval_to_check] << 'は 0 ~ 30 日の間で設定してください'
      end
    end

    def notify_min
      notify_at.min
    end

    def notify_hour
      notify_at.hour
    end

    def perform_later_check_tweet_job
      CheckExistenceOfPostJob
        .set(wait_until: self.check_tweet_existence_time)
        .perform_later(self.user)
    end
end
