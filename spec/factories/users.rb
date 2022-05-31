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

    trait :with_published_posts do
      after(:create) { |user| create_list(:post, 5, user: user) }
    end

    # NOTE: create_listh(name, amount, {trait, override...}) なので、量の後ろに書けばトレイトを呼び出せる
    trait :with_drafts do
      after(:create) { |user| create_list(:post, 5, :draft, user: user) }
    end

    trait :with_reserved_posts do
      after(:create) { |user| create_list(:post, 5, :reserved, user: user) }
    end
  end
end
