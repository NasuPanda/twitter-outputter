module Pages::SettingsHelper
  def can_notify(setting)
    if setting.can_notify?
      "ON"
    else
      "OFF"
    end
  end

  # NotificationSettingのnotify_atを見やすくする
  def notify_at(setting)
    if setting.notify_at
      l(setting.notify_at, format: :hour_and_min)
    else
      "設定されていません"
    end
  end

  # NotificationSettingのinterval_to_checkを見やすくする
  def interval_to_check(setting)
    if setting.interval_to_check
      "#{setting.interval_to_check}日"
    else
      "設定されていません"
    end
  end
end
