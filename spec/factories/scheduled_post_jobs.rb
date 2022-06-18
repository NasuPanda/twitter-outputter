FactoryBot.define do
  factory :scheduled_post_job do
    sequence(:job_id) { |i| "jobid#{i}" }
    status { 'scheduled' }
    association :post

    trait :failure do
      status { 'failure' }
    end
  end
end
