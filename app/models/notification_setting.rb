class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :can_notify, inclusion: [true, false]
  validates :notify_at, presence: true, if: Proc.new { |setting| setting.can_notify? }
  validate :interval_to_check_should_be_within_a_month, if: Proc.new { |setting| setting.can_notify? }

  # ツイート有無を確認する期間
  def check_tweet_existence_range
    min_day = Time.current
    max_day = interval_to_check.days.from_now
    return min_day.change(min: notify_min, hour: notify_hour), max_day.change(min: notify_min, hour: notify_hour)
  end

  # ツイート有無を確認する時
  def check_tweet_existence_time
    interval_to_check.days.from_now.change(min: notify_min, hour: notify_hour)
  end

  private

    def notify_min
      notify_at.min
    end

    def notify_hour
      notify_at.hour
    end

    # バリデーション(can_notifyのとき) : interval_to_checkが0~30の間であること
    def interval_to_check_should_be_within_a_month
      unless interval_to_check.between?(0, 30)
        errors[:interval_to_check] << 'は 0 ~ 30 日の間で設定してください'
      end
    end
end
