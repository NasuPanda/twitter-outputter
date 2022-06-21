module JobDeletable
  extend ActiveSupport::Concern

  private

    # NOTE: job_id, job_nameを持つことを前提とする
    def delete_job
      job = sidekiq_scheduled_set.scan(self.job_name).find { |job| job.jid == self.job_id }
      return unless job
      job.delete
    end

    def sidekiq_scheduled_set
      Sidekiq::ScheduledSet.new
    end
end