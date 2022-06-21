class CheckTweetJob < ApplicationRecord
  validates :job_id, presence: true, uniqueness: true

  before_destroy :delete_job
  before_update :delete_job

  belongs_to :notification_setting

  private

    # ジョブの削除, 更新前に古いジョブを削除する
    # TODO concernに切り出す
    def delete_job
      job = sidekiq_scheduled_set.scan("ReservePostJob").find { |job| job.jid == self.job_id }
      return unless job
      job.delete
    end

    def sidekiq_scheduled_set
      Sidekiq::ScheduledSet.new
    end
end
