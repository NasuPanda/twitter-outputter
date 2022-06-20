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

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        setting.notify_at = nil
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
