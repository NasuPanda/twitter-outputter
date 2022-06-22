FactoryBot.define do
  factory :notification_setting do
    can_notify { false }
    notify_at { Time.now }
    interval_to_check { rand(1..30) }
    association :user

    trait :with_job do
      after(:create) { |setting| FactoryBot.create(:check_tweet_job, notification_setting: setting) }
    end
  end
end
