class ScheduledPostJob < ApplicationRecord
  enum status: { scheduled: 0, failure: 1 }

  validates :job_id, presence: true, uniqueness: true

  before_destroy :delete_job
  before_update :delete_job

  belongs_to :post

  private

    # ジョブの削除, 更新前に古いジョブを削除する
    def delete_job
      ss = sidekiq_scheduled_set
      job = ss.scan("ReservePostJob").find { |job| job.jid == self.job_id }
      return unless job
      job.delete
    end

    def sidekiq_scheduled_set
      Sidekiq::ScheduledSet.new
    end
end
