FactoryBot.define do
  factory :tag do
    sequence(:name) { |i| "tag#{i}" }
    association :user
  end
end
