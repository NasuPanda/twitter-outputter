module Pages::SettingsHelper
  def can_notify(setting)
    setting.can_notify? ? 'ON' : 'OFF'
  end

  # NotificationSettingのnotify_atを見やすくする
  def notify_at(setting)
    setting.notify_at ? l(setting.notify_at, format: :hour_and_min) : '設定されていません'
  end

  # NotificationSettingのinterval_to_checkを見やすくする
  def interval_to_check(setting)
    setting.interval_to_check ? "#{setting.interval_to_check}日" : '設定されていません'
  end
end
