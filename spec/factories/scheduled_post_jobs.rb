FactoryBot.define do
  factory :scheduled_post_job do
    sequence(:job_id) { |i| "jobid#{i}" }
    status { 0 }
    association :post
  end
end
