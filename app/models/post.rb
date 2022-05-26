class Post < ApplicationRecord
  belongs_to :user

  validates :is_posted, inclusion: [true, false]
  validates :content, presence: true, length: { maximum: 140 }, uniqueness: { scope: :user_id }
  validate :post_at_cannot_be_blank_if_posted

  # TODO CRUDの実装

  private
    # バリデーション : 投稿済のとき、post_atは存在しなければならない
    def post_at_cannot_be_blank_if_posted
      if is_posted
        if post_at.blank?
          errors.add(:post_at, '投稿済のPostはpost_atカラムを持つ必要があります')
        end
      end
    end
end
