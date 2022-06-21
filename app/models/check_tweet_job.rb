class CheckTweetJob < ApplicationRecord
  include JobDeletable
  validates :job_id, presence: true, uniqueness: true

  # ジョブの削除, 更新前に古いジョブを削除する
  before_destroy :delete_job
  before_update  :delete_job

  belongs_to :notification_setting

  private

    # delete_job用
    def job_name
      "CheckExistenceOfPostJob"
    end
end
