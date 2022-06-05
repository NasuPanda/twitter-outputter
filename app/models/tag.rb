class Tag < ApplicationRecord
  include Twitter::TwitterText::Validation
  belongs_to :user
  # Twitterにおけるハッシュタグの最大文字数は100が上限のため
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id }
  validates :is_added, inclusion: [true, false]
  # タグのバリデーション(TwitterTextを利用)
  validate :name_should_be_valid_hashtag

  private

    # バリデーション : nameが有効なhashtagであること
    def name_should_be_valid_hashtag
      unless valid_hashtag?(self.name)
        tag.errors[:name] << '無効なハッシュタグです'
      end
    end
end
