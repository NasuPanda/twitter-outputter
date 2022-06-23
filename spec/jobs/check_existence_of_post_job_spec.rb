require 'rails_helper'

RSpec.describe CheckExistenceOfPostJob, type: :job do
  describe '#perform' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:notification_setting) { FactoryBot.create(:notification_setting, can_notify: true, user: user) }

    it 'ジョブがキューに入ること' do
      expect {
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
      }.to enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
    end

    context 'ツイートが特定期間に存在するとき' do
      before do
        allow_any_instance_of(User).to receive(:most_recent_tweet).and_return('recent tweet')
        allow_any_instance_of(CheckExistenceOfPostJob).to receive(:tweet_exist_in_period?).and_return(true)
      end

      it '指定時間にジョブが実行されること' do
        CheckExistenceOfPostJob
          .set(wait_until: notification_setting.check_tweet_existence_time)
          .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        # NOTE: after_performでジョブを再登録するので再起を防ぐため1つだけ実行
        expect {
          perform_enqueued_jobs(
            only: ->(job) {
              job['job_id'] == currently_queued_job['job_id'] }
          )
        }.to perform_job.at(notification_setting.check_tweet_existence_time)
      end

      it 'perform後にジョブがキューに追加されること' do
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        expect {
          perform_enqueued_jobs(
            only: ->(job) {
              job['job_id'] == currently_queued_job['job_id'] }
          )
        }.to enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end

      it 'perform後に追加されたジョブの実行時間がNotification_setting#check_tweet_existence_timeであること' do
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        expect {
          perform_enqueued_jobs(
            only: ->(job) {
              job['job_id'] == currently_queued_job['job_id'] }
          )
        }.to enqueue_job.at(notification_setting.check_tweet_existence_time)
      end

      it 'CreateNotification.callが呼ばれないこと' do
        allow(CreateNotification).to receive(:call)

        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        perform_enqueued_jobs(
          only: ->(job) {
            job['job_id'] == currently_queued_job['job_id'] }
        )
        expect(CreateNotification).to_not have_received(:call)
      end
    end

    context 'ツイートが特定期間に存在しないとき' do
      before do
        allow_any_instance_of(User).to receive(:most_recent_tweet).and_return(nil)
        allow_any_instance_of(CheckExistenceOfPostJob).to receive(:tweet_exist_in_period?).and_return(false)
        allow(CreateNotification).to receive(:call)
      end

      it 'perform後にジョブがキューに追加されること' do
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        expect {
          perform_enqueued_jobs(
            only: ->(job) {
              job['job_id'] == currently_queued_job['job_id'] }
          )
        }.to enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
      end

      it 'CreateNotification.callが1回呼ばれること' do
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
        currently_queued_job = enqueued_jobs.first

        perform_enqueued_jobs(
          only: ->(job) {
            job['job_id'] == currently_queued_job['job_id'] }
        )
        expect(CreateNotification).to have_received(:call).once
      end
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end
end
