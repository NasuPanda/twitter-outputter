FactoryBot.define do
  factory :post do
    sequence(:content) { |i| "content #{i}" }
    status { 'published' }
    post_at { rand(1..30).days.ago }
    association :user

    trait :draft do
      status { 'draft' }
    end

    trait :scheduled do
      status { 'scheduled' }
      post_at { rand(1..30).days.from_now }
    end
  end
end
