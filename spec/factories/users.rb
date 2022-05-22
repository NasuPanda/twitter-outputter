FactoryBot.define do
  factory :user do
    sequence(:external_user_id) { |i| "external-user-id#{i}" }

    trait :without_external_user_id do
      external_user_id { nil }
    end

    trait :with_authentication do
      after(:create) { |user| user.authentication = FactoryBot.build(:authentication) }
    end
  end
end
