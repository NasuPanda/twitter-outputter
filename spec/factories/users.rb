FactoryBot.define do
  factory :user do
    provider { "twitter" }
    sequence(:uid) { |i| "uid#{i}" }
  end
end
