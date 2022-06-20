class CreateNotificationSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :notification_settings do |t|
      # 通知機能のon/off
      t.boolean :can_notify, null: false, default: false
      # 通知する時間
      t.time :notify_at
      # tweetを確認する間隔
      t.integer :interval_to_check

      t.timestamps
    end

    add_reference :notification_settings, :user, null: false, foreign_key: true
  end
end
