FactoryBot.define do
  factory :post do
    sequence(:content) { |i| "content #{i}" }
    is_posted { true }
    post_at { rand(1..30).days.ago }
    association :user

    trait :draft do
      is_posted { false }
      post_at { nil }
    end
  end
end
