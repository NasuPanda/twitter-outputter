class Post < ApplicationRecord
  belongs_to :user

  validates :is_posted, inclusion: [true, false]
  # TODO カスタムバリデーション実装
  # 投稿済→presence: true, 下書き→存在しなくても良い(存在する場合予約投稿時間)
  validates :post_at, presence: true, allow_nil: true
  validates :content, presence: true, length: { maximum: 140 }

  # TODO CRUDの実装
end
