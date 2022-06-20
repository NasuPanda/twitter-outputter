class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :can_notify, inclusion: [true, false]
  validates :notify_at, presence: true, if: Proc.new { |setting| setting.can_notify? }
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

  private

    # バリデーション(can_notifyのとき) : interval_to_checkが0~30の間であること
    def interval_to_check_should_be_within_a_month
      unless interval_to_check.between?(0, 30)
        errors[:interval_to_check] << 'は 0 ~ 30 日の間で設定してください'
      end
    end
end
