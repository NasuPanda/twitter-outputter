FactoryBot.define do
  factory :notification_setting do
    can_notify { false }
    notify_at { '0800' }
    interval_to_check { rand(1..30) }
    association :user
  end
end
