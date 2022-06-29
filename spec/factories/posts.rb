FactoryBot.define do
  factory :post do
    sequence(:content) { |i| "content #{i}" }
    association :user

    trait :draft do
      status { 'draft' }
      post_at { nil }
    end

    trait :scheduled do
      status { 'scheduled' }
      post_at { rand(1..30).days.from_now }
    end

    trait :published do
      status { 'published' }
      post_at { rand(1..30).days.ago }
    end

    trait :with_job do
      after(:create) { |post| FactoryBot.create(:scheduled_post_job, post: post) }
    end

    trait :with_failure_job do
      after(:create) { |post| FactoryBot.create(:scheduled_post_job, :failure, post: post) }
    end

    trait :with_image do
      after(:create) do |post|
      post.images.attach(
        Rack::Test::UploadedFile.new(
          "#{Rails.root}/spec/fixtures/400x400.png", 'image/png'
        )
      )
      end
    end
  end
end
