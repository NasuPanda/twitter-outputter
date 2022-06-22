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

  describe '#check_tweet_existence_range' do
    # 2022/4/1/8:00で固定する
    before { travel_to(Time.zone.local(2022, 4, 1, 8, 0, 0)) }

    context 'can_notifyがfalseのとき' do
      let(:setting) { FactoryBot.create(:notification_setting, can_notify: false) }
      it 'nilが返ること' do
        expect(setting.check_tweet_existence_range).to be_nil
      end
    end

    context 'notify_atが6:30, interval_to_checkが2のとき' do
      let(:setting) {
        FactoryBot.create(
          :notification_setting,
          can_notify: true,
          notify_at: Time.zone.local(2022, 4, 1, 6, 30, 0),
          interval_to_check: 2
        )
      }
      it '2022/3/30 6:30, 2022/4/1 6:30が返ること' do
        time_range = setting.check_tweet_existence_range
        expect(time_range[0]).to eq(Time.zone.local(2022, 3, 30, 6, 30, 0))
        expect(time_range[1]).to eq(Time.zone.local(2022, 4, 1, 6, 30, 0))
      end
    end

    context 'notify_atが0:00, interval_to_checkが30のとき' do
      let(:setting) {
        FactoryBot.create(
          :notification_setting,
          can_notify: true,
          notify_at: Time.zone.local(2022, 4, 1, 0, 0, 0),
          interval_to_check: 30
        )
      }
      it '2022/3/2 0:00, 2022/4/1 0:00が返ること' do
        time_range = setting.check_tweet_existence_range
        expect(time_range[0]).to eq(Time.zone.local(2022, 3, 2, 0, 0, 0))
        expect(time_range[1]).to eq(Time.zone.local(2022, 4, 1, 0, 0, 0))
      end
    end
  end

  describe '#check_tweet_existence_time' do
    before { travel_to(Time.zone.local(2022, 4, 1, 8, 0, 0)) }

    context 'can_notifyがfalseのとき' do
      let(:setting) { FactoryBot.create(:notification_setting, can_notify: false) }
      it 'nilが返ること' do
        expect(setting.check_tweet_existence_time).to be_nil
      end
    end

    context 'notify_atが6:30, interval_to_checkが2のとき' do
      let(:setting) {
        FactoryBot.create(
          :notification_setting,
          can_notify: true,
          notify_at: Time.zone.local(2022, 4, 1, 6, 30, 0),
          interval_to_check: 2
          )
        }
      it '2022/4/3 6:30が返ること' do
        expect(setting.check_tweet_existence_time).to eq(Time.zone.local(2022, 4, 3, 6, 30, 0))
      end
    end

    context 'notify_atが0:00, interval_to_checkが30のとき' do
      let(:setting) {
        FactoryBot.create(
          :notification_setting,
          can_notify: true,
          notify_at: Time.zone.local(2022, 4, 1, 0, 0, 0),
          interval_to_check: 30
        )
      }
      it '2022/5/1 0:00が返ること' do
        expect(setting.check_tweet_existence_time).to eq(Time.zone.local(2022, 5, 1, 0, 0, 0))
      end
    end
  end

  describe '#set_check_tweet_job' do
    context 'can_notifyがtrueのとき' do
      let!(:setting) { FactoryBot.create(:notification_setting, can_notify: true) }

      it 'CheckTweetJobが作成されること' do
        # ジョブのモック化
        job_mock = double('PostJob')
        allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
        allow_any_instance_of(NotificationSetting).to receive(:perform_later_check_tweet_job).and_return(job_mock)

        expect {
          setting.set_check_tweet_job
        }.to change{ CheckTweetJob.count }.by(1)
      end

      it 'ジョブがキューに入ること' do
        # ジョブをモック化すると振る舞いが変わってしまうのでモック化しない
        expect {
          setting.set_check_tweet_job
        }.to enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end
    end

    context 'can_notifyがfalseのとき' do
      let!(:setting) { FactoryBot.create(:notification_setting, can_notify: false) }

      it 'CheckTweetJobが作成されないこと' do
        # ジョブのモック化
        job_mock = double('PostJob')
        allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
        allow_any_instance_of(NotificationSetting).to receive(:perform_later_check_tweet_job).and_return(job_mock)

        expect {
          setting.set_check_tweet_job
        }.to_not change{ CheckTweetJob.count }
      end

      it 'ジョブがキューに入らないこと' do
        # ジョブをモック化すると振る舞いが変わってしまうのでモック化しない
        expect {
          setting.set_check_tweet_job
        }.to_not enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end
    end
  end

  describe '#update_check_tweet_job' do
    context 'can_notifyがtrueかつCheckTweetJobを持つとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, :with_job, can_notify: true)
      }

      it 'CheckTweetJobが更新されること' do
        # ジョブのモック化
        job_mock = double('PostJob')
        allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
        allow_any_instance_of(NotificationSetting).to receive(:perform_later_check_tweet_job).and_return(job_mock)
        expect {
          setting.update_check_tweet_job
        }.to change{ setting.reload.check_tweet_job.job_id }
      end
    end

    context 'CheckTweetJobを持つがcan_notifyがfalseのとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, :with_job, can_notify: false)
      }

      it 'CheckTweetJobが更新されないこと' do
        # ジョブのモック化
        job_mock = double('PostJob')
        allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
        allow_any_instance_of(NotificationSetting).to receive(:perform_later_check_tweet_job).and_return(job_mock)

        expect {
          setting.update_check_tweet_job
        }.to_not change{ setting.reload.check_tweet_job.job_id }
      end

      it 'ジョブがキューに入らないこと' do
        expect {
          setting.update_check_tweet_job
        }.to_not enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end
    end

    context 'can_notifyがtrueだがCheckTweetJobを持たないとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, can_notify: true)
      }

      it '実行後CheckTweetJobを持たないこと' do
        # ジョブのモック化
        job_mock = double('PostJob')
        allow(job_mock).to receive(:provider_job_id).and_return('random_job_id')
        allow_any_instance_of(NotificationSetting).to receive(:perform_later_check_tweet_job).and_return(job_mock)

        setting.update_check_tweet_job
        expect(setting.reload.check_tweet_job).to be_nil
      end

      it 'ジョブがキューに入らないこと' do
        expect {
          setting.update_check_tweet_job
        }.to_not enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end
    end
  end

  describe '#cancel_check_tweet_job' do
    context 'can_notifyがfalseかつCheckTweetJobを持つとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, :with_job, can_notify: false)
      }

      it 'CheckTweetJobが削除されること' do
        expect {
          setting.cancel_check_tweet_job
        }.to change{ CheckTweetJob.count }.by(-1)
      end
    end

    context 'CheckTweetJobを持つがcan_notifyがtrueのとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, :with_job, can_notify: true)
      }

      it 'CheckTweetJobが削除されないこと' do
        expect {
          setting.cancel_check_tweet_job
        }.to_not change{ CheckTweetJob.count }
      end
    end

    context 'can_notifyがfalseだがCheckTweetJobを持たないとき' do
      let!(:setting) {
        FactoryBot.create(:notification_setting, can_notify: false)
      }

      it 'returnすること' do
        expect(setting.cancel_check_tweet_job).to be_nil
      end
    end
  end

  describe '#job_action' do
    context 'can_notifyがtrueかつCheckTweetJobを持つとき' do
      let(:setting) { FactoryBot.create(:notification_setting, :with_job, can_notify: true) }

      it 'updateを返すこと' do
        expect(setting.job_action).to eq('update')
      end
    end

    context 'can_notifyがtrueかつCheckTweetJobを持たないとき' do
      let(:setting) { FactoryBot.create(:notification_setting, can_notify: true) }

      it 'createを返すこと' do
        expect(setting.job_action).to eq('create')
      end
    end

    context 'can_notifyがfalseかつCheckTweetJobを持つとき' do
      let(:setting) { FactoryBot.create(:notification_setting, :with_job, can_notify: false) }

      it 'destroyを返すこと' do
        expect(setting.job_action).to eq('destroy')
      end
    end
  end
end