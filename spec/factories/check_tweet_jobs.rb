FactoryBot.define do
  factory :check_tweet_job do
    sequence(:job_id) { |i| "jobid#{i}" }
    association :notification_setting
  end
end
