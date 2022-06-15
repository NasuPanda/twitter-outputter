class CreateScheduledPostJob < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduled_post_jobs do |t|
      t.string :job_id
      t.integer :status, default: 0

      t.timestamps
    end

    add_reference :scheduled_post_jobs, :post, null: false, foreign_key: true
  end
end
