FactoryBot.define do
  factory :user do
    sequence(:external_user_id) { |i| "external-user-id#{i}" }

    trait :with_authentication do
      after(:create) { |user| user.authentication = FactoryBot.create(:authentication) }
    end

    trait :with_tag do
      after(:create) { |user| user.tags << FactoryBot.create(:tag) }
    end

    trait :with_post do
      after(:create) { |user| user.posts << FactoryBot.create(:post) }
    end

    # NOTE: create_listh(name, amount, {trait, override...})
    trait :with_published_posts do
      after(:create) { |user| create_list(:post, 5, user: user) }
    end

    trait :with_drafts do
      after(:create) { |user| create_list(:post, 5, :draft, user: user) }
    end

    trait :with_scheduled_posts do
      after(:create) { |user| create_list(:post, 5, :scheduled, user: user) }
    end

    trait :with_tagged_tags do
      after(:create) { |user| create_list(:tag, 5, :tagged, user: user) }
    end
  end
end
