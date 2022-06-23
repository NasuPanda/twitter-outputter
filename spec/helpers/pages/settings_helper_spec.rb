require 'rails_helper'

RSpec.describe Pages::SettingsHelper, type: :helper do
  describe 'can_notify' do
    context 'setting.can_notifyがtrueのとき' do
      it 'ON を返すこと' do
        setting = double('Setting', can_notify?: true)
        expect(helper.can_notify(setting)).to eq('ON')
      end
    end

    context 'setting.can_notifyがfalseのとき' do
      it 'OFF を返すこと' do
        setting = double('Setting', can_notify?: false)
        expect(helper.can_notify(setting)).to eq('OFF')
      end
    end
  end

  describe 'notify_at' do
    context 'setting.notify_atが存在するとき' do
      it '%H:%M形式を返すこと' do
        # NOTE: 必要なのは時, 分のみ
        setting_0600 = double('Setting', notify_at: Time.zone.local(2000, 1, 1, 6, 0, 0))
        setting_0830 = double('Setting', notify_at: Time.zone.local(2000, 1, 1, 8, 30, 0))
        setting_2015 = double('Setting', notify_at: Time.zone.local(2000, 1, 1, 20, 15, 0))
        expect(helper.notify_at(setting_0600)).to eq('06:00')
        expect(helper.notify_at(setting_0830)).to eq('08:30')
        expect(helper.notify_at(setting_2015)).to eq('20:15')
      end
    end

    context 'setting.notify_atが存在しないとき' do
      it '設定されていません を返すこと' do
        setting = double('Setting', notify_at: nil)
        expect(helper.notify_at(setting)).to eq('設定されていません')
      end
    end
  end

  describe 'interval_to_check' do
    context 'setting.interval_to_checkが存在するとき' do
      it 'N日形式を返すこと' do
        setting_1 = double('Setting', interval_to_check: 1)
        setting_15 = double('Setting', interval_to_check: 15)
        setting_30 = double('Setting', interval_to_check: 30)
        expect(helper.interval_to_check(setting_1)).to eq('1日')
        expect(helper.interval_to_check(setting_15)).to eq('15日')
        expect(helper.interval_to_check(setting_30)).to eq('30日')
      end
    end

    context 'setting.interval_to_checkが存在しないとき' do
      it '設定されていません を返すこと' do
        setting = double('Setting', interval_to_check: nil)
        expect(helper.interval_to_check(setting)).to eq('設定されていません')
      end
    end
  end
end