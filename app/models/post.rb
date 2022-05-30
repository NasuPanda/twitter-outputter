class Post < ApplicationRecord
  enum status: { draft: 0, reserved: 1, published: 2 }

  belongs_to :user

  validates :content, presence: true, length: { maximum: 140 }, uniqueness: { scope: :user_id }
  validate :post_at_cannot_be_blank_if_reserved_or_published

  # TODO CRUDの実装

  private

    # バリデーション : 投稿予約状態または投稿済のとき、post_atは存在しなければならない
    def post_at_cannot_be_blank_if_reserved_or_published
      if reserved? || published?
        if post_at.blank?
          errors.add(:post_at, '投稿予約状態または投稿済のPostはpost_atカラムを持つ必要があります')
        end
      end
    end
end
