FactoryBot.define do
  factory :post do
    sequence(:content) { |i| "content #{i}" }
    association :user

    trait :draft do
      status { 'draft' }
      post_at { nil }
    end

    trait :scheduled do
      status { 'scheduled' }
      post_at { rand(1..30).days.from_now }
    end

    trait :published do
      status { 'published' }
      post_at { rand(1..30).days.ago }
    end
  end
end
