class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :can_notify, inclusion: [true, false]
  validate :notify_at_should_be_valid, if: Proc.new { |setting| setting.can_notify? }
  validate :interval_to_check_should_be_within_a_month, if: Proc.new { |setting| setting.can_notify? }

=begin
  # to_aで現在時刻に関する情報を取得
    # sec, min, hour, mday, mon, year, wday, yday, isdst, zone = Time.current.to_a

  # Time.gmで現在の日付+特定の時間のdatatimeを取得
    # Time.gm(0, 0, 20, mday, mon, year, wday, yday, isdst, zone)
    # => 2022-06-19 20:00:00 UTC

  # つまりコレでいい
    # time = Time.current.to_a
    # notify_at = Time.gm(0, min, hour, *time[3..9])
=end

  def self.concat_notify_hour_and_min(hour, minute)
    hour = hour.to_s.rjust(2, '0')
    minute = minute.to_s.rjust(2, '0')
    return hour + minute
  end

  def notify_hour
    return unless notify_at
    notify_at[0..1]
  end

  def notify_min
    return unless notify_at
    notify_at[2..3]
  end

  private

    # バリデーション(can_notifyのとき) : notify_atが'0000'~'2359'の間であること
    def notify_at_should_be_valid
      if !notify_hour.between?('00', '23') || !notify_min.between?('00', '59')
        errors[:notify_at] << 'は 0:00 ~ 23:59 の間で設定してください'
      end
    end

    # バリデーション(can_notifyのとき) : interval_to_checkが0~30の間であること
    def interval_to_check_should_be_within_a_month
      unless interval_to_check.between?(0, 30)
        errors[:interval_to_check] << 'は 0 ~ 30 日の間で設定してください'
      end
    end
end
