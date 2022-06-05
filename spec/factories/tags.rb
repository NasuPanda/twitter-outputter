FactoryBot.define do
  factory :tag do
    sequence(:name) { |i| "#tag#{i}" }
    is_added { false }
    association :user
  end
end
