FactoryBot.define do
  factory :post do
    sequence(:content) { |i| "content #{i}" }
    status { 'published' }
    post_at { rand(1..30).days.ago }
    association :user

    trait :draft do
      status { 'draft' }
    end

    trait :reserved do
      status { 'reserved' }
    end
  end
end
