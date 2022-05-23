FactoryBot.define do
  factory :user do
    sequence(:external_user_id) { |i| "external-user-id#{i}" }

    trait :without_external_user_id do
      external_user_id { nil }
    end

    trait :with_authentication do
      after(:create) { |user| user.authentication = FactoryBot.build(:authentication) }
    end

    trait :with_post do
      after(:create) { |user| user.posts << FactoryBot.create(:post) }
    end

    trait :with_tag do
      after(:create) { |user| user.tags << FactoryBot.create(:tag) }
    end
  end
end
