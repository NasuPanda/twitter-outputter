class ScheduledPostJob < ApplicationRecord
  include JobDeletable
  enum status: { scheduled: 0, failure: 1 }
  validates :job_id, presence: true, uniqueness: true

  # ジョブの削除, 更新前に古いジョブを削除する
  before_destroy :delete_job
  before_update  :delete_job

  belongs_to :post

  private

    # delete_job用
    def job_name
      'ReservePostJob'
    end
end
