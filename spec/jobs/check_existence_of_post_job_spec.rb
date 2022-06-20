require 'rails_helper'

RSpec.describe CheckExistenceOfPostJob, type: :job do
  describe '#perform' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:notification_setting) { FactoryBot.create(:notification_setting, notify_at: true, user: user) }

    it 'ジョブがキューに入ること' do
      expect {
        CheckExistenceOfPostJob
        .set(wait_until: notification_setting.check_tweet_existence_time)
        .perform_later(user)
      }.to enqueue_job(CheckExistenceOfPostJob).on_queue(:check_post)
    end

    describe 'ジョブ実行のテスト' do
      before do
        allow_any_instance_of(User).to receive(:most_recent_tweet).and_return('recent tweet')
        allow_any_instance_of(CheckExistenceOfPostJob).to receive(:tweet_exist?).and_return(true)
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
    end


    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end
end
