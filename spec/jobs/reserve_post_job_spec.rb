require 'rails_helper'

RSpec.describe ReservePostJob, type: :job do
  describe '#perform' do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    let!(:scheduled_post) { FactoryBot.create(:post, :scheduled, :with_job) }

    it 'ジョブがキューに追加されること' do
      expect {
        ReservePostJob.set(wait_until: scheduled_post.post_at).perform_later(
          user, scheduled_post.id, scheduled_post.updated_at
        )
      }.to enqueue_job(ReservePostJob)
    end

    it 'ジョブの実行時間を指定できること' do
      expect {
        ReservePostJob.set(wait_until: scheduled_post.post_at).perform_later(
          user, scheduled_post.id, scheduled_post.updated_at
        )
      }.to enqueue_job.at(scheduled_post.post_at)
    end

    describe 'ジョブ実行のテスト' do
      before do
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
        # HACK: post_tweetをモック化するために allow_any_instanc_of を使っている
        allow_any_instance_of(ReservePostJob).to receive(:post_tweet).and_return('tweet')
      end

      it '指定時間にジョブが実行されること' do
        expect {
          ReservePostJob.set(wait_until: scheduled_post.post_at).perform_later(
            user, scheduled_post.id, scheduled_post.updated_at
          )
        }.to perform_job.at(scheduled_post.post_at)
      end

      it 'ジョブ実行後にPostがpublishedになっていること' do
        ReservePostJob.set(wait_until: scheduled_post.post_at).perform_later(
          user, scheduled_post.id, scheduled_post.updated_at
        )
        expect(scheduled_post.reload.published?).to be_truthy
      end

      it 'ジョブ実行後にPost.ScheduledPostJobが削除されていること' do
        ReservePostJob.set(wait_until: scheduled_post.post_at).perform_later(
          user, scheduled_post.id, scheduled_post.updated_at
        )
        expect(scheduled_post.reload.scheduled_post_job).to be_blank
      end
    end
  end
end
