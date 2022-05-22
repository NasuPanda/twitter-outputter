FactoryBot.define do
  factory :authentication do
    sequence(:uid) { |n| "user_#{n}" }
    sequence(:access_token) { |n| "token_#{n}" }
    sequence(:access_token_secret) { |n| "token_secret_#{n}" }
    association :user
  end
end
