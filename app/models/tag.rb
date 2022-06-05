class Tag < ApplicationRecord
  include Twitter::TwitterText::Validation

  # ハッシュマークから始まらない場合はハッシュマークを付与する
  before_validation :prepend_hashmark_to_name, unless: :name_is_blank_or_start_with_hashmark?
  belongs_to :user
  # Twitterにおけるハッシュタグの最大文字数は100が上限のため
  validates :name, presence: true, length: { maximum: 101 }, uniqueness: { scope: :user_id }
  validates :is_added, inclusion: [true, false]
  # タグのバリデーション(TwitterTextを利用)
  validate :name_should_be_valid_hashtag

  private

    # バリデーション : nameが有効なhashtagであること
    def name_should_be_valid_hashtag
      unless valid_hashtag?(self.name)
        self.errors[:name] << '無効なハッシュタグです'
      end
    end

    # 先頭にハッシュマークを付与する
    def prepend_hashmark_to_name
      self.name = self.name.prepend('#') if self.name.present?
    end

    # ハッシュマークから始まるかどうか判定する
    def name_is_blank_or_start_with_hashmark?
      if self.name.blank?
        return true
      end
      return self.name.start_with?('#')
    end
end
