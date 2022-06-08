FactoryBot.define do
  factory :tag do
    sequence(:name) { |i| "#tag#{i}" }
    is_tagged { false }
    association :user

    trait :tagged do
      is_tagged { true }
    end
  end
end
