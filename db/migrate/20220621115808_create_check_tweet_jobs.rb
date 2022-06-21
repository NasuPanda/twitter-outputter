class CreateCheckTweetJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :check_tweet_jobs do |t|
      t.string :job_id, null: false

      t.timestamps
    end

    add_reference :check_tweet_jobs, :notification_setting, null: false, foreign_key: true
  end
end
