FactoryBot.define do
  factory :authentication do
    user_id { 1 }
    uid { "MyString" }
    access_token { "MyString" }
    access_token_secret { "MyString" }
  end
end
