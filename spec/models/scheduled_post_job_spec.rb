require 'rails_helper'

RSpec.describe ScheduledPostJob, type: :model do
  describe 'attribute: job_id' do
    let(:scheduled_post_job) { FactoryBot.build(:scheduled_post_job) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(scheduled_post_job).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        scheduled_post_job.job_id = nil
        expect(scheduled_post_job).to be_invalid
      end
    end
  end

  describe 'attribute: status' do
    let(:post) { FactoryBot.create(:post) }

    context '新規作成するとき' do
      it 'デフォルトでscheduledであること' do
        post.create_scheduled_post_job(job_id: 'random_job_id')
        expect(post.scheduled_post_job).to be_scheduled
      end
    end
  end

  describe 'before_action' do
    let(:scheduled_post_job) { FactoryBot.build(:scheduled_post_job) }
    before { allow(scheduled_post_job).to receive(:delete_job) }

    describe 'before_update' do
      it 'delete_jobが実行されること' do
        scheduled_post_job.update(job_id: 'updated')
        expect(scheduled_post_job).to have_received(:delete_job).once
      end
    end

    describe 'before_destroy' do
      it 'delete_jobが実行されること' do
        scheduled_post_job.destroy
        expect(scheduled_post_job).to have_received(:delete_job).once
      end
    end
  end
end
