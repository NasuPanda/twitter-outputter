require 'rails_helper'

RSpec.describe CheckTweetJob, type: :model do
  describe 'attribute: job_id' do
    let(:check_tweet_job) { FactoryBot.build(:check_tweet_job) }

    context '存在するとき' do
      it 'バリデーションに成功すること' do
        expect(check_tweet_job).to be_valid
      end
    end

    context '存在しないとき' do
      it 'バリデーションに失敗すること' do
        check_tweet_job.job_id = nil
        expect(check_tweet_job).to be_invalid
      end
    end
  end

  describe 'before_action' do
    let(:check_tweet_job) { FactoryBot.create(:check_tweet_job) }
    before { allow(check_tweet_job).to receive(:delete_job) }

    describe 'before_update' do
      it 'delete_jobが実行されること' do
        check_tweet_job.update!(job_id: 'updated')
        expect(check_tweet_job).to have_received(:delete_job).once
      end
    end

    describe 'before_destroy' do
      it 'delete_jobが実行されること' do
        check_tweet_job.destroy!
        expect(check_tweet_job).to have_received(:delete_job).once
      end
    end
  end
end
