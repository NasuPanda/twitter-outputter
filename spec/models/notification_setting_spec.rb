require 'rails_helper'

RSpec.describe NotificationSetting, type: :model do
  describe 'attribute: can_notify' do
    let(:setting) { FactoryBot.create(:notification_setting) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(setting).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        setting.can_notify = nil
        expect(setting).to be_invalid
      end
    end
  end

  describe 'attribute: notify_at' do
    # バリデーションはcan_notifyの時のみ働くのでtrueにしておく
    let(:setting) { FactoryBot.create(:notification_setting, can_notify: true) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(setting).to be_valid
      end
    end

    context '0000のとき' do
      it 'バリデーションに成功すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(0, 0)

        setting.notify_at = notify_at
        expect(setting).to be_valid
      end
    end

    context '2359のとき' do
      it 'バリデーションに成功すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(23, 59)

        setting.notify_at = notify_at
        expect(setting).to be_valid
      end
    end

    context 'hourが-1のとき' do
      it 'バリデーションに失敗すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(-1, setting.notify_min)
        p notify_at
        setting.notify_at = notify_at
        expect(setting).to be_invalid
      end
    end

    context 'hourが24のとき' do
      it 'バリデーションに失敗すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(24, setting.notify_min)

        setting.notify_at = notify_at
        expect(setting).to be_invalid
      end
    end

    context 'minが-1のとき' do
      it 'バリデーションに失敗すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(setting.notify_hour, -1)

        setting.notify_at = notify_at
        expect(setting).to be_invalid
      end
    end

    context 'minが60のとき' do
      it 'バリデーションに失敗すること' do
        notify_at = NotificationSetting.concat_notify_hour_and_min(setting.notify_hour, 60)

        setting.notify_at = notify_at
        expect(setting).to be_invalid
      end
    end
  end

  describe 'attribute: interval_to_check' do
    # バリデーションはcan_notifyの時のみ働くのでtrueにしておく
    let(:setting) { FactoryBot.create(:notification_setting, can_notify: true) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(setting).to be_valid
      end
    end

    context '-1のとき' do
      it 'バリデーションに失敗すること' do
        setting.interval_to_check = -1
        expect(setting).to be_invalid
      end
    end

    context '31のとき' do
      it 'バリデーションに失敗すること' do
        setting.interval_to_check = 31
        expect(setting).to be_invalid
      end
    end
  end

  describe 'belongs_to: User' do
    let!(:setting) { FactoryBot.create(:notification_setting) }
    let!(:user) { setting.user }

    it 'Userが削除されるとき一緒に削除されること' do
      expect {
        user.destroy!
      }.to change{ NotificationSetting.count }.by(-1)
    end
  end
end
